import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final courseKey = studentData['kurs'] ?? '';
    final courseModulesRaw = allModules[courseKey]?['semesters'];
    Map<String, List<Map<String, dynamic>>> courseModules = {};

    if (courseModulesRaw is Map) {
      courseModulesRaw.forEach((semesterKey, semesterValue) {
        final modulesList = <Map<String, dynamic>>[];
        if (semesterValue is Map && semesterValue['modules'] is List) {
          for (var m in semesterValue['modules']) {
            if (m is Map) {
              modulesList.add(Map<String, dynamic>.from(m));
            }
          }
        }
        courseModules[semesterKey] = modulesList;
      });
    }

    final selectedModulesRaw = studentData['selectedModules'];
    Map<String, List<String>> selectedModules = {};
    if (selectedModulesRaw is Map) {
      selectedModulesRaw.forEach((key, value) {
        if (value is List) {
          selectedModules[key.toString()] = value.map((e) => e.toString()).toList();
        } else {
          selectedModules[key.toString()] = [];
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
          title: Text('${studentData['name'] ?? ''} ${studentData['surname'] ?? ''}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $studentId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Kurs: $courseKey', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // Выбранные модули
            Text('Ausgewählte Module:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            ...selectedModules.entries.map((e) {
              final semester = e.key;
              final modules = e.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(semester, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...modules.map((m) => Text('- $m')),
                  const SizedBox(height: 5),
                ],
              );
            }),

            const SizedBox(height: 20),

            // Все доступные модули для курса
            Text('Alle verfügbaren Module:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            ...courseModules.entries.map((e) {
              final semester = e.key;
              final modules = e.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(semester, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...modules.map((m) => Text('- ${m['name'] ?? ''} (${m['dozent'] ?? ''})')),
                  const SizedBox(height: 5),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
