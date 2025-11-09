import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';
import '../widgets/semester_card.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  final Map<String, dynamic> allModules;

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
  static const int maxModulesPerSemester = 2;

  @override
  void initState() {
    super.initState();
    selectedModules = {};
    initialModules = {};
    final raw = widget.student['selectedModules'];
    if (raw != null && raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          selectedModules[key.toString()] = value.map((e) => e.toString()).toList();
          initialModules[key.toString()] = List<String>.from(selectedModules[key]!);
        } else {
          selectedModules[key.toString()] = [];
          initialModules[key.toString()] = [];
        }
      });
    } else {
      selectedModules = {'wpm1': [], 'wpm2': [], 'wpm3': []};
      initialModules = {'wpm1': [], 'wpm2': [], 'wpm3': []};
    }
  }

  bool get isModified {
    for (var key in selectedModules.keys) {
      final current = selectedModules[key] ?? [];
      final initial = initialModules[key] ?? [];
      if (current.length != initial.length ||
          !_listEquals(current, initial)) {
        return true;
      }
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

  void _onModuleChanged(String semester, String moduleName, bool isSelected) {
    final current = selectedModules[semester] ?? [];
    if (isSelected) {
      if (current.length >= maxModulesPerSemester) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Sie können maximal $maxModulesPerSemester Module für $semester auswählen'),
          ),
        );
        return;
      }
      current.add(moduleName);
    } else {
      current.remove(moduleName);
    }
    setState(() {
      selectedModules[semester] = current;
    });

    FirebaseServices.saveSelectedModules(
      widget.student['id'],
      selectedModules,
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseKey = widget.student['kurs'] ?? '';
    final courseData = widget.allModules[courseKey];
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Student Info ---
            Card(
              color: AppColors.card(context),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    Text('Kurs: ${widget.student['kurs']?.toUpperCase() ?? ''}',
                        style: AppTextStyles.body(context)),
                  ],
                ),
              ),
            ),

            // --- Save Button ---
            Card(
              color: AppColors.card(context),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    onPressed: isModified
                        ? () async {
                            await FirebaseServices.saveSelectedModules(
                                widget.student['id'], selectedModules);
                            if (!mounted) return;
                            initialModules = selectedModules.map(
                                (key, value) =>
                                    MapEntry(key, List<String>.from(value)));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Auswahl gespeichert!')),
                            );
                            setState(() {});
                          }
                        : null,
                    child: const Text(
                      'Speichern',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            // --- Semester Sections via SemesterCard ---
            ...courseModules.entries.map((entry) {
              final semester = entry.key;
              final modules = entry.value;

              String openDate = 'nicht angegeben';
              String closeDate = 'nicht angegeben';
              if (courseModulesRaw[semester] != null &&
                  courseModulesRaw[semester] is Map) {
                openDate =
                    courseModulesRaw[semester]['chooseOpenDate'] ?? 'nicht angegeben';
                closeDate =
                    courseModulesRaw[semester]['chooseCloseDate'] ??
                        'nicht angegeben';
              }

              return SemesterCard(
                semester: semester,
                openDate: openDate,
                closeDate: closeDate,
                modules: modules,
                selectedModules: selectedModules,
                maxModulesPerSemester: maxModulesPerSemester,
                onModuleChanged: (moduleName, isSelected) =>
                    _onModuleChanged(semester, moduleName, isSelected),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
