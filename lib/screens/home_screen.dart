import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';
import '../utils/recalculate_participants.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';
import '../widgets/semester_card.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  final Map<String, dynamic> allModules; // первоначальные данные модуля, можно перезаписать локально

  const HomeScreen({
    super.key,
    required this.student,
    required this.allModules,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, List<String>> selectedModules;
  late Map<String, List<String>> initialModules;
  late Map<String, dynamic> modulesData; // локальная копия modules (для обновления после save)
  static const int maxModulesPerSemester = 2;
  bool _isLoadingParticipants = true;

  @override
  void initState() {
    super.initState();

    // Локально храним modules (чтобы после recalc и getModules обновлять UI)
    modulesData = Map<String, dynamic>.from(widget.allModules);

    selectedModules = {};
    initialModules = {};

    final raw = widget.student['selectedModules'];
    if (raw != null && raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          selectedModules[key.toString()] =
              value.map((e) => e.toString()).toList();
          initialModules[key.toString()] =
              List<String>.from(selectedModules[key]!);
        } else {
          selectedModules[key.toString()] = [];
          initialModules[key.toString()] = [];
        }
      });
    } else {
      selectedModules = {'wpm1': [], 'wpm2': [], 'wpm3': []};
      initialModules = {'wpm1': [], 'wpm2': [], 'wpm3': []};
    }

    // Пересчёт участников при старте (опционально) и загрузка свежих modules
    _refreshModulesAndCounts();
  }

  Future<void> _refreshModulesAndCounts() async {
    setState(() => _isLoadingParticipants = true);
    // запустим пересчёт на сервере и затем подгрузим актуальные модули
    await recalcParticipants();
    final latestModules = await FirebaseServices.getModules();
    if (latestModules.isNotEmpty) {
      modulesData = latestModules;
    }
    setState(() => _isLoadingParticipants = false);
  }

  bool get isModified {
    for (var key in selectedModules.keys) {
      final current = selectedModules[key] ?? [];
      final initial = initialModules[key] ?? [];
      if (!_listEquals(current, initial)) return true;
    }
    return false;
  }

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// При смене выбора — меняем только локально selectedModules.
  void _onModuleChanged(String semester, String moduleName, bool isSelected) {
    final current = List<String>.from(selectedModules[semester] ?? []);

    // Проверка ограничения на выбор
    if (isSelected && current.length >= maxModulesPerSemester) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Sie können maximal $maxModulesPerSemester Module für $semester auswählen.'),
        ),
      );
      return;
    }

    // Реальные изменения в локальной структуре
    setState(() {
      if (isSelected) {
        if (!current.contains(moduleName)) current.add(moduleName);
      } else {
        current.remove(moduleName);
      }
      selectedModules[semester] = current;
    });

    // НИЧЕГО НЕ отправляем в базу до нажатия Save
  }

  /// Нажатие кнопки "Speichern" — сохраняем выбор студента и пересчитываем участников,
  /// затем загружаем свежие модули для обновления UI.
  Future<void> _onSavePressed() async {
    setState(() => _isLoadingParticipants = true);

    try {
      // 1) Сохраняем выбранные модули студента
      await FirebaseServices.saveSelectedModules(
        widget.student['id'],
        selectedModules,
      );

      // 2) Пересчитываем всех участников на сервере (recalcParticipants),
      //    затем получаем актуальные данные modules из БД
      await recalcParticipants();
      final latestModules = await FirebaseServices.getModules();
      if (latestModules.isNotEmpty) {
        modulesData = latestModules;
      }

      // 3) Обновляем initialModules (теперь текущее состояние — "сохранённое")
      initialModules = selectedModules.map((k, v) => MapEntry(k, List<String>.from(v)));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auswahl gespeichert!')),
      );
    } catch (e) {
      print('Ошибка при сохранении: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Speichern')),
      );
    } finally {
      setState(() => _isLoadingParticipants = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseKey = widget.student['kurs'] ?? '';
    final courseData = modulesData[courseKey];
    final courseModulesRaw = courseData?['semesters'] ?? {};
    Map<String, List<Map<String, dynamic>>> courseModules = {};

    courseModulesRaw.forEach((semesterKey, semesterValue) {
      final modulesList = <Map<String, dynamic>>[];
      if (semesterValue != null &&
          semesterValue is Map &&
          semesterValue['modules'] is List) {
        for (var m in semesterValue['modules']) {
          if (m != null && m is Map) {
            modulesList.add(Map<String, dynamic>.from(m));
          }
        }
      }
      courseModules[semesterKey] = modulesList;
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundMain(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Backstage DHGE',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
      ),
      body: _isLoadingParticipants
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Student Info ---
                  Card(
                    color: AppColors.card(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Schülerinformationen',
                              style: AppTextStyles.subheading(context)),
                          const SizedBox(height: 8),
                          Text('Vorname: ${widget.student['name'] ?? ''}',
                              style: AppTextStyles.body(context)),
                          Text('Nachname: ${widget.student['surname'] ?? ''}',
                              style: AppTextStyles.body(context)),
                          Text(
                              'Kurs: ${widget.student['kurs']?.toUpperCase() ?? ''}',
                              style: AppTextStyles.body(context)),
                        ],
                      ),
                    ),
                  ),

                  // --- Save Button ---
                  Card(
                    color: AppColors.card(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isModified
                                ? AppColors.secondary
                                : AppColors.secondary.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: isModified ? _onSavePressed : null,
                          child: const Text(
                            'Speichern',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --- Semester Sections ---
                  ...courseModules.entries.map((entry) {
                    final semester = entry.key;
                    final modules = entry.value;

                    String openDate = 'nicht angegeben';
                    String closeDate = 'nicht angegeben';
                    if (courseModulesRaw[semester] != null &&
                        courseModulesRaw[semester] is Map) {
                      openDate = courseModulesRaw[semester]['chooseOpenDate'] ??
                          'nicht angegeben';
                      closeDate = courseModulesRaw[semester]
                              ['chooseCloseDate'] ??
                          'nicht angegeben';
                    }

                    return SemesterCard(
                      semester: semester,
                      openDate: openDate,
                      closeDate: closeDate,
                      modules: modules,
                      selectedModules: selectedModules,
                      maxModulesPerSemester: maxModulesPerSemester,
                      onModuleChanged: (moduleName, isSelected) {
                        _onModuleChanged(semester, moduleName, isSelected);
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
