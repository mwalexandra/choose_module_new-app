import 'package:firebase_database/firebase_database.dart';

final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

class FirebaseServices {
  // Получить всех студентов
  static Future<Map<String, dynamic>> getStudents() async {
    final snapshot = await databaseReference.child('students').get();
    if (snapshot.exists) {
      final value = snapshot.value;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      } else {
        return {};
      }
    } else {
      return {};
    }
  }

  // Получить одного студента по ID
  static Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    final snapshot = await databaseReference.child('students/$studentId').get();
    if (snapshot.exists) {
      final value = snapshot.value;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      } else {
        // Если это не Map, можно вернуть null или обработать по-другому
        return null;
      }
    } else {
      return null;
    }
  }
}
