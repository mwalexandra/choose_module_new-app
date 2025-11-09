import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';

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
  static const int maxModulesPerSemester = 2;

  @override
  void initState() {
    super.initState();
    selectedModules = {};
    final raw = widget.student['selectedModules'];
    if (raw != null && raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          selectedModules[key.toString()] = value.map((e) => e.toString()).toList();
        } else {
          selectedModules[key.toString()] = [];
        }
      });
    } else {
      selectedModules = {
        'wpm1': [],
        'wpm2': [],
        'wpm3': [],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseKey = widget.student['kurs'] ?? '';
    final courseModulesRaw = widget.allModules[courseKey]?['semesters'];
    Map<String, List<Map<String, dynamic>>> courseModules = {};

    if (courseModulesRaw != null && courseModulesRaw is Map) {
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
    } else {
      courseModules = {
        'wpm1': [],
        'wpm2': [],
        'wpm3': [],
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Backstage DHGE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await FirebaseServices.saveSelectedModules(
                  widget.student['id'], selectedModules);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Auswahl gespeichert!')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Information Section
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Information über den Studenten',
                      style: AppTextStyles.subheading().copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text('Vorname: ${widget.student['name'] ?? ''}',
                        style: AppTextStyles.body().copyWith(fontSize: 16)),
                    Text('Nachname: ${widget.student['surname'] ?? ''}',
                        style: AppTextStyles.body().copyWith(fontSize: 16)),
                    Text('Kurs: ${widget.student['kurs'] ?? ''}',
                        style: AppTextStyles.body().copyWith(fontSize: 16)),
                  ],
                ),
              ),
            ),

            // Module Selection Section
            ...courseModules.entries.map((e) {
              final semester = e.key;
              final modules = e.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    semester,
                    style: AppTextStyles.subheading().copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ...modules.map((m) {
                    final moduleName = m['name'] ?? '';
                    final moduleDozent = m['dozent'] ?? '';
                    final isSelected =
                        selectedModules[semester]?.contains(moduleName) ?? false;

                    return CheckboxListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                      title: Text('$moduleName ($moduleDozent)',
                          style: AppTextStyles.body().copyWith(fontSize: 16)),
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          final selectedList = selectedModules[semester] ??= [];
                          if (val == true) {
                            if (selectedList.length >= maxModulesPerSemester) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Sie können nicht mehr als $maxModulesPerSemester Module für $semester auswählen'),
                                ),
                              );
                            } else {
                              if (!selectedList.contains(moduleName)) {
                                selectedList.add(moduleName);
                              }
                            }
                          } else {
                            selectedList.remove(moduleName);
                          }
                        });
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
