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
      selectedModules = {
        'wpm1': [],
        'wpm2': [],
        'wpm3': [],
      };
      initialModules = {
        'wpm1': [],
        'wpm2': [],
        'wpm3': [],
      };
    }
  }

  bool get isModified {
    for (var key in selectedModules.keys) {
      final current = selectedModules[key] ?? [];
      final initial = initialModules[key] ?? [];
      if (current.length != initial.length ||
          !ListEquality().equals(current, initial)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final courseKey = widget.student['kurs'] ?? '';
    final courseData = widget.allModules[courseKey];
    final courseModulesRaw = courseData?['semesters'];
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
                    Text('Kurs: ${widget.student['kurs'].toUpperCase() ?? ''}',
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
                    onPressed: isModified
                        ? () async {
                            await FirebaseServices.saveSelectedModules(
                                widget.student['id'], selectedModules);
                            if (!mounted) return;
                            initialModules = selectedModules.map(
                                (key, value) => MapEntry(key, List<String>.from(value)));
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

            // --- Semester Sections ---
            ...courseModules.entries.map((e) {
              final semester = e.key;
              final modules = e.value;

              String openDate = 'nicht angegeben';
              String closeDate = 'nicht angegeben';
              if (courseModulesRaw != null &&
                  courseModulesRaw[semester] != null &&
                  courseModulesRaw[semester] is Map) {
                openDate = courseModulesRaw[semester]['chooseOpenDate'] ?? 'nicht angegeben';
                closeDate = courseModulesRaw[semester]['chooseCloseDate'] ?? 'nicht angegeben';
              }

              return StatefulBuilder(
                builder: (context, setTileState) {
                  bool isExpanded = false;

                  return Card(
                    color: AppColors.card(context),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedBackgroundColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                        onExpansionChanged: (expanded) {
                          setTileState(() => isExpanded = expanded);
                        },
                        title: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isExpanded 
                            ? AppColors.sectionHeaderActive(context)
                            : AppColors.sectionHeaderInactive(context),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                semester.toUpperCase(),
                                style: AppTextStyles.subheading(context),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Wahltermine: von $openDate bis $closeDate',
                                style: AppTextStyles.body(context).copyWith(
                                  color: AppColors.textPrimary(context).withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        children: modules.map((m) {
                          final moduleName = m['name'] ?? '';
                          final moduleDozent = m['dozent'] ?? '';
                          final isSelected =
                              selectedModules[semester]?.contains(moduleName) ?? false;

                          return CheckboxListTile(
                            activeColor: AppColors.primary,
                            checkColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            title: Text(
                              '$moduleName ($moduleDozent)',
                              style: AppTextStyles.body(context),
                            ),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                final selectedList = selectedModules[semester] ??= [];
                                if (val == true) {
                                  if (selectedList.length >= maxModulesPerSemester) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Sie können maximal $maxModulesPerSemester Module für $semester auswählen'),
                                      ),
                                    );
                                  } else if (!selectedList.contains(moduleName)) {
                                    selectedList.add(moduleName);
                                  }
                                } else {
                                  selectedList.remove(moduleName);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class ListEquality {
  bool equals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
