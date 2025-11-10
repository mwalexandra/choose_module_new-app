import 'semester.dart';
import 'module.dart';

class Student {
  final String id;
  final String name;
  final String surname;
  final String kurs;
  final List<Semester> semesters;

  Student({
    required this.id,
    required this.name,
    required this.surname,
    required this.kurs,
    required this.semesters,
  });

  factory Student.fromMap(String id, Map<String, dynamic> map,
      Map<String, dynamic> allModules) {
    final name = map['name'] ?? '';
    final surname = map['surname'] ?? '';
    final kurs = map['kurs'] ?? '';
    final selectedModulesRaw = map['selectedModules'] ?? {};

    final courseModulesRaw = allModules[kurs]?['semesters'] ?? {};
    final semesters = <Semester>[];

    courseModulesRaw.forEach((semesterKey, semesterDataRaw) {
      if (semesterDataRaw is Map) {
        final semester = Semester.fromMap(semesterKey, Map<String, dynamic>.from(semesterDataRaw));
        // Отмечаем выбранные модули
        final selectedList = selectedModulesRaw[semesterKey] ?? [];
        for (var module in semester.modules) {
          if (selectedList.contains(module.name)) {
            module.isSelected = true;
          }
        }
        semesters.add(semester);
      }
    });

    return Student(
      id: id,
      name: name,
      surname: surname,
      kurs: kurs,
      semesters: semesters,
    );
  }

  Map<String, dynamic> toMap() {
    final selectedModules = <String, List<String>>{};
    for (var semester in semesters) {
      selectedModules[semester.name] = semester.modules
          .where((m) => m.isSelected)
          .map((m) => m.name)
          .toList();
    }

    return {
      'name': name,
      'surname': surname,
      'kurs': kurs,
      'selectedModules': selectedModules,
    };
  }
}
