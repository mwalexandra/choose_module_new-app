import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, dynamic> students = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  // Получаем всех студентов из Firebase
  void fetchStudents() async {
    final data = await FirebaseServices.getStudents();
    setState(() {
      students = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final key = students.keys.elementAt(index);
                final student = students[key];
                final name = student['name'] ?? '';
                final surname = student['surname'] ?? '';

                return ListTile(
                  title: Text('$name $surname'),
                  onTap: () {
                    // Переходим на home_screen через именованный маршрут
                    Navigator.pushNamed(
                      context,
                      '/home',
                      arguments: {
                        'studentId': key,
                        'studentData': student,
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
