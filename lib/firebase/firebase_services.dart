import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

class FirebaseServices {

  /// Получить всех студентов
  static Future<Map<String, dynamic>> getStudents() async {
    try {
      final snapshot = await databaseReference.child('students').get();
      if (snapshot.exists && snapshot.value != null) {
        return _convertSnapshotToMap(snapshot.value);
      }
    } catch (e) {
      print('Ошибка при getStudents: $e');
    }
    return {};
  }

  /// Получить одного студента по ID
  static Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    try {
      final snapshot = await databaseReference.child('students/$studentId').get();
      if (snapshot.exists && snapshot.value != null) {
        return _convertSnapshotToMap(snapshot.value);
      }
    } catch (e) {
      print('Ошибка при getStudentById($studentId): $e');
    }
    return null;
  }

  /// Получить все модули
  static Future<Map<String, dynamic>> getModules() async {
    try {
      final snapshot = await databaseReference.child('modules').get();
      if (snapshot.exists && snapshot.value != null) {
        return _convertSnapshotToMap(snapshot.value);
      }
    } catch (e) {
      print('Ошибка при getModules: $e');
    }
    return {};
  }

  /// Добавить нового студента
  static Future<void> addStudent(String studentId, Map<String, dynamic> data) async {
    try {
      await databaseReference.child('students/$studentId').set(data);
    } catch (e) {
      print('Ошибка при addStudent: $e');
    }
  }

  /// Обновить данные студента
  static Future<void> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      await databaseReference.child('students/$studentId').update(data);
    } catch (e) {
      print('Ошибка при updateStudent: $e');
    }
  }

  /// Сохранить выбранные модули студента
  static Future<void> saveSelectedModules(
      String studentId, Map<String, List<String>> selectedModules) async {
    try {
      await databaseReference
          .child('students/$studentId/selectedModules')
          .set(selectedModules);
    } catch (e) {
      print('Ошибка при saveSelectedModules: $e');
    }
  }

  /// Обновить количество участников модуля
  static Future<void> updateModuleParticipants(
      String courseId, String semester, String moduleName, int participants) async {
    try {
      await databaseReference
          .child('modules/$courseId/semesters/$semester/modules')
          .get()
          .then((snapshot) async {
        if (snapshot.exists && snapshot.value != null) {
          final modulesList = _convertSnapshotToList(snapshot.value);
          for (int i = 0; i < modulesList.length; i++) {
            if (modulesList[i]['name'] == moduleName) {
              modulesList[i]['participants'] = participants;
              break;
            }
          }
          // Сохраняем обратно весь список модулей
          await databaseReference
              .child('modules/$courseId/semesters/$semester/modules')
              .set(modulesList);
        }
      });
    } catch (e) {
      print('Ошибка при updateModuleParticipants: $e');
    }
  }

  /// Удалить студента
  static Future<void> deleteStudent(String studentId) async {
    try {
      await databaseReference.child('students/$studentId').remove();
    } catch (e) {
      print('Ошибка при deleteStudent: $e');
    }
  }

  /// Универсальное преобразование snapshot.value в Map<String, dynamic>
  static Map<String, dynamic> _convertSnapshotToMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    } else if (value != null) {
      return Map<String, dynamic>.from(jsonDecode(jsonEncode(value)));
    } else {
      return {};
    }
  }

  /// Преобразовать snapshot.value в List<Map<String, dynamic>>
  static List<Map<String, dynamic>> _convertSnapshotToList(dynamic value) {
    if (value is List) {
      return value.map((e) {
        if (e is Map) return Map<String, dynamic>.from(e.cast<String, dynamic>());
        return <String, dynamic>{};
      }).toList();
    } else if (value is Map) {
      return value.entries
          .map((e) => Map<String, dynamic>.from((e.value as Map).cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  static Map<String, dynamic> deepConvertMap(Map<Object?, Object?> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final newKey = key.toString();
      if (value is Map) {
        result[newKey] = deepConvertMap(Map<Object?, Object?>.from(value));
      } else if (value is List) {
        result[newKey] = value.map((e) {
          if (e is Map) return deepConvertMap(Map<Object?, Object?>.from(e));
          return e;
        }).toList();
      } else {
        result[newKey] = value;
      }
    });
    return result;
  }

  /// Увеличить количество участников модуля
  static Future<void> incrementParticipants(String semester, String moduleName) async {
    final ref = databaseReference.child('modules/$semester/modules');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      final modules = List<Map<String, dynamic>>.from(
          (snapshot.value as List).map((e) => Map<String, dynamic>.from(e))
      );
      for (var module in modules) {
        if (module['name'] == moduleName) {
          module['participants'] = (module['participants'] ?? 0) + 1;
          break;
        }
      }
      await ref.set(modules);
    }
  }

  /// Уменьшить количество участников модуля
  static Future<void> decrementParticipants(String semester, String moduleName) async {
    final ref = databaseReference.child('modules/$semester/modules');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      final modules = List<Map<String, dynamic>>.from(
          (snapshot.value as List).map((e) => Map<String, dynamic>.from(e))
      );
      for (var module in modules) {
        if (module['name'] == moduleName) {
          module['participants'] = ((module['participants'] ?? 1) - 1).clamp(0, 999);
          break;
        }
      }
      await ref.set(modules);
    }
  }

  /// Обновить все модули целиком
static Future<void> updateModules(Map<String, dynamic> modules) async {
  try {
    await databaseReference.child('modules').set(modules);
  } catch (e) {
    print('Ошибка при updateModules: $e');
  }
}
}
