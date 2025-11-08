import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String studentId;
  final Map<String, dynamic> studentData;

  const HomeScreen({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${studentData['name']} ${studentData['surname']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $studentId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Kurs: ${studentData['kurs'] ?? ''}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Ausgewählte Module:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            ...?studentData['selectedModules']?.entries.map((e) {
              final semester = e.key;
              final modules = List<String>.from(e.value ?? []);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(semester, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...modules.map((m) => Text('- $m')),
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
