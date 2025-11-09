import 'package:firebase_database/firebase_database.dart';

final DatabaseReference database = FirebaseDatabase.instance.ref();

/// Пересчёт участников для всех модулей
Future<void> recalcParticipants() async {
  try {
    // --- Получаем всех студентов ---
    final studentsSnapshot = await database.child('students').get();
    if (!studentsSnapshot.exists || studentsSnapshot.value == null) return;

    final studentsRaw = studentsSnapshot.value as Map<dynamic, dynamic>;
    final students = studentsRaw.map((key, value) {
      return MapEntry(key.toString(), Map<String, dynamic>.from(value as Map));
    });

    // --- Считаем участников для каждого модуля ---
    final Map<String, Map<String, int>> participantsCount = {};

    for (var student in students.values) {
      final selectedModulesRaw = student['selectedModules'] ?? {};
      if (selectedModulesRaw is! Map) continue;

      final selectedModules = selectedModulesRaw.map((key, value) {
        return MapEntry(key.toString(), value is List ? value.map((e) => e.toString()).toList() : <String>[]);
      });

      selectedModules.forEach((semester, modulesList) {
        participantsCount.putIfAbsent(semester, () => {});
        for (var moduleName in modulesList) {
          participantsCount[semester]!.update(moduleName, (v) => v + 1, ifAbsent: () => 1);
        }
      });
    }

    // --- Обновляем базу данных с новым числом участников ---
    final modulesSnapshot = await database.child('modules').get();
    if (!modulesSnapshot.exists || modulesSnapshot.value == null) return;

    final modulesRaw = modulesSnapshot.value as Map<dynamic, dynamic>;
    final updatedModules = <String, dynamic>{};

    modulesRaw.forEach((semesterKey, semesterDataRaw) {
      final semesterData = Map<String, dynamic>.from(semesterDataRaw as Map);
      final modulesListRaw = semesterData['modules'] ?? [];
      final modulesList = <Map<String, dynamic>>[];

      if (modulesListRaw is List) {
        for (var m in modulesListRaw) {
          if (m is Map) {
            modulesList.add(Map<String, dynamic>.from(m));
          }
        }
      }

      for (var module in modulesList) {
        final name = module['name'] ?? '';
        final count = participantsCount[semesterKey]?.containsKey(name) == true
            ? participantsCount[semesterKey]![name]!
            : 0;
        module['participants'] = count;
      }

      semesterData['modules'] = modulesList;
      updatedModules[semesterKey.toString()] = semesterData;
    });

    await database.child('modules').set(updatedModules);
    print('Количество участников пересчитано и обновлено!');
  } catch (e) {
    print('Ошибка при пересчёте участников: $e');
  }
}
