import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;
  final Map<String, dynamic> allModules;

  const HomeScreen({
    super.key,
    required this.studentId,
    required this.studentData,
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
    // Копируем выбранные модули студента
    selectedModules = {};
    final raw = widget.studentData['selectedModules'];
    if (raw != null && raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          selectedModules[key.toString()] = value.map((e) => e.toString()).toList();
        } else {
          selectedModules[key.toString()] = [];
        }
      });
    } else {
      // Если нет selectedModules, создаём пустые семестры
      selectedModules = {
        'wpm1': [],
        'wpm2': [],
        'wpm3': [],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseKey = widget.studentData['kurs'] ?? '';
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
      // Если нет данных по курсу, создаём пустую структуру
      courseModules = {
        'wpm1': [],
        'wpm2': [],
        'wpm3': [],
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.studentData['name']} ${widget.studentData['surname']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await FirebaseServices.saveSelectedModules(
                  widget.studentId, selectedModules);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Auswahl gespeichert!')));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: courseModules.entries.map((e) {
            final semester = e.key;
            final modules = e.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(semester,
                    style: AppTextStyles.subheading()),
                ...modules.map((m) {
                  final moduleName = m['name'] ?? '';
                  final isSelected =
                      selectedModules[semester]?.contains(moduleName) ?? false;

                  return CheckboxListTile(
                    title: Text('$moduleName (${m['dozent'] ?? ''})',
                        style: AppTextStyles.body()),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        final selectedList = selectedModules[semester] ??= [];
                        if (val == true) {
                          if (selectedList.length >= maxModulesPerSemester) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Вы можете выбрать не более $maxModulesPerSemester модулей для $semester'),
                            ));
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
                const SizedBox(height: 10),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
