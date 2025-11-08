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

  /// Пример: добавить нового студента
  static Future<void> addStudent(String studentId, Map<String, dynamic> data) async {
    try {
      await databaseReference.child('students/$studentId').set(data);
    } catch (e) {
      print('Ошибка при addStudent: $e');
    }
  }

  /// Пример: обновить данные студента
  static Future<void> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      await databaseReference.child('students/$studentId').update(data);
    } catch (e) {
      print('Ошибка при updateStudent: $e');
    }
  }

  /// Пример: созранить выбранные модули студента
  static Future<void> saveSelectedModules(
    String studentId, Map<String, List<String>> selectedModules) async {
    await databaseReference
        .child('students/$studentId/selectedModules')
        .set(selectedModules);
  }

  /// Пример: удалить студента
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
      // На Web snapshot.value может быть JS Object
      return Map<String, dynamic>.from(jsonDecode(jsonEncode(value)));
    } else {
      return {};
    }
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
}
