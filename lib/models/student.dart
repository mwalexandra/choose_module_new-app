import 'semester.dart';
import 'module.dart';

class Student {
  final String id;
  final String name;
  final String surname;
  final String course;
  final String password;
  final String email;
  final List<Semester> semesters;

  Student({
    required this.id,
    required this.name,
    required this.surname,
    required this.course,
    required this.password,
    required this.semesters,
    required this.email,
  });

  factory Student.fromMap(String id, Map<String, dynamic> map,
      Map<String, dynamic> allModules) {
    final name = map['name'] ?? '';
    final surname = map['surname'] ?? '';
    final course = map['course'] ?? '';
    final selectedModulesRaw = map['selectedModules'] ?? {};
    final password = map['password'] ?? '';
    final email = map['email'] ?? '';

    final courseModulesRaw = allModules[course]?['semesters'] ?? {};
    final semesters = <Semester>[];

    courseModulesRaw.forEach((semesterKey, semesterDataRaw) {
      if (semesterDataRaw is Map) {
        final semester = Semester.fromMap(
            semesterKey, Map<String, dynamic>.from(semesterDataRaw));
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
      course: course,
      semesters: semesters,
      password: password,
      email: email,
    );
  }

  Student copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? password,
    List<Semester>? semesters,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      password: password ?? this.password,
      course: course,
      semesters: semesters ?? this.semesters,
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
      'course': course,
      'selectedModules': selectedModules,
      'email': email,
      'password': password,
    };
  }
}
