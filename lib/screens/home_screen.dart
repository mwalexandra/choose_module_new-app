import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';
import '../widgets/semester_card.dart';
import '../models/student.dart';
import '../models/semester.dart';
import '../models/module.dart';
import '../utils/recalculate_participants.dart';

class HomeScreen extends StatefulWidget {
  final Student student;

  const HomeScreen({super.key, required this.student});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Student _studentCopy; // локальная копия студента
  static const int maxModulesPerSemester = 2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() => _isLoading = true);

    try {
      final modulesData = await FirebaseServices.getModules();

      final List<Semester> semesters = [];
      final courseKey = widget.student.course;
      final courseData = modulesData[courseKey]?['semesters'] ?? {};

      courseData.forEach((semKey, semVal) {
        final open = semVal['chooseOpenDate'] != null
            ? DateTime.tryParse(semVal['chooseOpenDate'])
            : DateTime.now().subtract(const Duration(days: 1));
        final close = semVal['chooseCloseDate'] != null
            ? DateTime.tryParse(semVal['chooseCloseDate'])
            : DateTime.now().add(const Duration(days: 1));

        final modulesList = <Module>[];
        if (semVal['modules'] != null && semVal['modules'] is List) {
          for (var m in semVal['modules']) {
            if (m is Map) {
              final module = Module.fromMap(Map<String, dynamic>.from(m));

              final originalSemester = widget.student.semesters.firstWhere(
                  (s) => s.name == semKey,
                  orElse: () => Semester(
                      name: semKey,
                      openDate: open ?? DateTime.now(),
                      closeDate: close ?? DateTime.now(),
                      modules: []));
              final isSelected = originalSemester.modules
                  .any((mod) => mod.name == module.name && mod.isSelected);

              module.isSelected = isSelected;

              if (isSelected) {
                module.participants = (module.participants ?? 0) + 1;
              }

              modulesList.add(module);
            }
          }
        }

        semesters.add(Semester(
          name: semKey,
          openDate: open ?? DateTime.now(),
          closeDate: close ?? DateTime.now(),
          modules: modulesList,
        ));
      });

      // создаём локальную копию студента с актуальными данными и email/name
      _studentCopy = widget.student.copyWith(
        semesters: semesters,
        name: widget.student.name,
        email: widget.student.email,
      );
    } catch (e) {
      print('Fehler beim Laden der Studiendaten: $e');
      _studentCopy = widget.student;
    }

    setState(() => _isLoading = false);
  }

  bool get isModified {
    for (var i = 0; i < _studentCopy.semesters.length; i++) {
      final semester = _studentCopy.semesters[i];
      final originalSemester = widget.student.semesters[i];

      for (var j = 0; j < semester.modules.length; j++) {
        if (semester.modules[j].isSelected !=
            originalSemester.modules[j].isSelected) {
          return true;
        }
      }
    }
    return false;
  }

  void _onModuleChanged(Module module) {
    setState(() {});
  }

  Future<void> _onSavePressed() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, List<String>> selectedMap = {};
      for (var semester in _studentCopy.semesters) {
        selectedMap[semester.name] =
            semester.modules.where((m) => m.isSelected).map((m) => m.name).toList();
      }

      await FirebaseServices.saveSelectedModules(_studentCopy.id, selectedMap);
      await recalcParticipants();
      await _loadStudentData();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auswahl gespeichert!')));
    } catch (e) {
      print('Fehler beim Speichern: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fehler beim Speichern')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Backstage DHGE',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Info
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
                          Text('Vorname: ${_studentCopy.name}',
                              style: AppTextStyles.body(context)),
                          Text('Nachname: ${_studentCopy.surname}',
                              style: AppTextStyles.body(context)),
                          Text('Email: ${_studentCopy.email}',
                              style: AppTextStyles.body(context)),
                          Text('Kurs: ${_studentCopy.course.toUpperCase()}',
                              style: AppTextStyles.body(context)),
                        ],
                      ),
                    ),
                  ),

                  // Save Button
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
                          child: const Text('Speichern',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),

                  // Semester Cards
                  ..._studentCopy.semesters.map((semester) {
                    return SemesterCard(
                      semester: semester,
                      maxModulesPerSemester: maxModulesPerSemester,
                      onModuleChanged: _onModuleChanged,
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
