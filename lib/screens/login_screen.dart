import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, dynamic> students = {};
  Map<String, dynamic> allModules = {};
  bool isLoadingStudents = true;
  bool isLoadingModules = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
    fetchModules();
  }

  void fetchStudents() async {
    final data = await FirebaseServices.getStudents();
    if (!mounted) return;
    setState(() {
      students = deepConvertMap(Map<Object?, Object?>.from(data));
      isLoadingStudents = false;
    });
  }

  void fetchModules() async {
    final data = await FirebaseServices.getModules();
    if (!mounted) return;
    setState(() {
      allModules = deepConvertMap(Map<Object?, Object?>.from(data));
      isLoadingModules = false;
    });
  }

  /// Рекурсивное преобразование LinkedMap<Object, Object> в Map<String, dynamic>
  Map<String, dynamic> deepConvertMap(Map<Object?, Object?> map) {
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

  @override
  Widget build(BuildContext context) {
    final isLoading = isLoadingStudents || isLoadingModules;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final key = students.keys.elementAt(index);
                final student = students[key] ?? {};
                final name = student['name'] ?? '';
                final surname = student['surname'] ?? '';

                return ListTile(
                  title: Text('$name $surname'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/home',
                      arguments: {
                        'studentId': key,
                        'studentData': student,
                        'allModules': allModules,
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
