import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

final DatabaseReference database = FirebaseDatabase.instance.ref();

/// Neuberechnung der Teilnehmeranzahl für alle Module anhand der Struktur:
/// modules -> <courseId> -> { ..., semesters: { <semesterKey>: { modules: [ {id,name,participants,...}, ... ] } } }
Future<void> recalcParticipants() async {
  try {
  // --- 1) Zählen der Modulwahlen der Studierenden: course -> semester -> moduleName -> count
    final studentsSnapshot = await database.child('students').get();
    if (!studentsSnapshot.exists || studentsSnapshot.value == null) return;

    final studentsRaw = studentsSnapshot.value;
    // Normalize to Map<String, dynamic>
    final Map<String, dynamic> students = (studentsRaw is Map)
        ? Map<String, dynamic>.from(studentsRaw.cast())
        : <String, dynamic>{};

    final Map<String, Map<String, Map<String, int>>> counts = {};
    for (final studentEntry in students.entries) {
      final student = studentEntry.value;
      if (student is! Map) continue;
      final courseId = (student['kurs'] ?? '').toString();
      if (courseId.isEmpty) continue;

      final selectedRaw = student['selectedModules'];
      if (selectedRaw == null || selectedRaw is! Map) continue;

      final selected = Map<String, dynamic>.from(selectedRaw.cast());
      selected.forEach((semesterKey, modulesValue) {
        final moduleList = <String>[];
        if (modulesValue is List) {
          for (var e in modulesValue) {
            moduleList.add(e?.toString() ?? '');
          }
        }
        if (moduleList.isEmpty) return;
        counts.putIfAbsent(courseId, () => {});
        counts[courseId]!.putIfAbsent(semesterKey, () => {});
        for (final moduleName in moduleList) {
          if (moduleName.isEmpty) continue;
          counts[courseId]![semesterKey]!.update(moduleName, (v) => v + 1,
              ifAbsent: () => 1);
        }
      });
    }

  // --- 2) Durchlauf aller Kurse/Semester in modules und Aktualisierung der participants
    final modulesSnapshot = await database.child('modules').get();
    if (!modulesSnapshot.exists || modulesSnapshot.value == null) return;

    final modulesRaw = modulesSnapshot.value;
      if (modulesRaw is! Map<String, dynamic>) return;

  // Für jede courseId aktualisieren wir deren semesters -> modules
      for (final courseEntry in modulesRaw.entries) {
      final courseId = courseEntry.key.toString();
      final courseDataRaw = courseEntry.value;
      if (courseDataRaw == null || courseDataRaw is! Map) continue;

      final courseData = Map<String, dynamic>.from(courseDataRaw.cast());
      final semestersRaw = courseData['semesters'];
      if (semestersRaw == null || semestersRaw is! Map) continue;

  // Aktualisierte Struktur der Semester (oder wir schreiben Module einzeln zurück)
        for (final semesterEntry in semestersRaw.entries) {
        final semesterKey = semesterEntry.key.toString();
        final semesterDataRaw = semesterEntry.value;
        if (semesterDataRaw == null || semesterDataRaw is! Map) continue;

        final semesterData = Map<String, dynamic>.from(semesterDataRaw.cast());
        final modulesListRaw = semesterData['modules'];

        final List<Map<String, dynamic>> modulesList = [];
        if (modulesListRaw is List) {
          for (var m in modulesListRaw) {
            if (m is Map) {
              modulesList.add(Map<String, dynamic>.from(m.cast()));
            }
          }
        } else if (modulesListRaw is Map) {
          // Für den Fall, dass Module als Map<index, {...}> gespeichert sind
          for (final mEntry in modulesListRaw.entries) {
            if (mEntry.value is Map) {
              modulesList.add(Map<String, dynamic>.from((mEntry.value as Map).cast()));
            }
          }
        }

        // Für jedes Modul setzen wir participants = counts[courseId]?[semesterKey]?[moduleName] ?? 0
        for (final module in modulesList) {
          final name = (module['name'] ?? '').toString();
          final newCount = counts[courseId] != null &&
                  counts[courseId]![semesterKey] != null &&
                  counts[courseId]![semesterKey]!.containsKey(name)
              ? counts[courseId]![semesterKey]![name]!
              : 0;
          module['participants'] = newCount;
        }

    // Speichern der Modulliste dieses Semesters zurück in die DB
        await database
            .child('modules/$courseId/semesters/$semesterKey/modules')
            .set(modulesList);
      }
    }

    debugPrint('recalcParticipants: Teilnehmerzahlen erfolgreich aktualisiert');
  } catch (e, st) {
    debugPrint('Fehler beim recalcParticipants: $e\n$st');
  }
}
