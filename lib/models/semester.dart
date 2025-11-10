import 'module.dart';

class Semester {
  final String name;
  final DateTime openDate;
  final DateTime closeDate;
  final List<Module> modules;

  Semester({
    required this.name,
    required this.openDate,
    required this.closeDate,
    required this.modules,
  });

  factory Semester.fromMap(String name, Map<String, dynamic> map) {
    final openDate = DateTime.tryParse(map['chooseOpenDate'] ?? '') ??
        DateTime.now().subtract(const Duration(days: 1));
    final closeDate = DateTime.tryParse(map['chooseCloseDate'] ?? '') ??
        DateTime.now().add(const Duration(days: 1));

    final modulesList = <Module>[];
    if (map['modules'] != null && map['modules'] is List) {
      for (var m in map['modules']) {
        if (m is Map) {
          modulesList.add(Module.fromMap(Map<String, dynamic>.from(m)));
        }
      }
    }

    return Semester(
      name: name,
      openDate: openDate,
      closeDate: closeDate,
      modules: modulesList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chooseOpenDate': openDate.toIso8601String(),
      'chooseCloseDate': closeDate.toIso8601String(),
      'modules': modules.map((m) => m.toMap()).toList(),
    };
  }

  bool isSelectionActive() {
    final now = DateTime.now();
    return now.isAfter(openDate) && now.isBefore(closeDate);
  }
}
