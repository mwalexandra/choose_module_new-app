import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';
import '../models/student.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';
import '../utils/web_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final studentId = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (studentId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte ID und Passwort eingeben')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Загружаем данные студента из Firebase
      final studentsData = await FirebaseServices.getStudents();

      if (!studentsData.containsKey(studentId)) {
        throw 'Student nicht gefunden';
      }

      final studentMap = Map<String, dynamic>.from(studentsData[studentId]);

      if (studentMap['password'] != password) {
        throw 'Falsches Passwort';
      }

      // Создаём объект Student
      final allModules = await FirebaseServices.getModules();
      final student = Student.fromMap(studentId, studentMap, allModules);
      final routePath = '#/home/${student.id}';
      // Обновляем URL для веб-версии
      pushWebRoute(routePath);
      // Переходим на HomeScreen
      Navigator.pushNamed(
        context,
        '/home',
        arguments: {'student': student},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login fehlgeschlagen: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain(context),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Backstage DHGE Login', style: AppTextStyles.heading(context)),
              const SizedBox(height: 32),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Passwort',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Login', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
