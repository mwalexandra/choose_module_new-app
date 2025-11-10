import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';
import '../models/student.dart';
import '../models/semester.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Map<String, dynamic> studentsData = {};
  Map<String, dynamic> allModules = {};
  bool isLoading = true;
  bool isLoggingIn = false;

  @override
    void initState() {
      super.initState();
      fetchData();
  }

  void fetchData() async {
    final studentData = await FirebaseServices.getStudents();
    final modulesData = await FirebaseServices.getModules();

    if (!mounted) return;

    setState(() {
      studentsData = deepConvertMap(Map<Object?, Object?>.from(studentData));
      allModules = deepConvertMap(Map<Object?, Object?>.from(modulesData));
      isLoading = false;
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

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    final studentId = _studentIdController.text.trim();
    final password = _passwordController.text;

    final studentMap = studentsData[studentId];
    if (studentMap == null) {
      _showError('Student ID ist nicht gefunden');
      return;
    }

    if (studentMap['password'] != password) {
      _showError('Passwort ist falsch');
      return;
    }

    setState(() => isLoggingIn = true);

    try {
      final student = Student.fromMap(studentId, studentMap, allModules);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(student: student),
        ),
      );
    } catch (e) {
      _showError('Fehler beim Einloggen: $e');
    } finally {
      if (mounted) setState(() => isLoggingIn = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain(context),
      appBar: AppBar(
        title: Text('Backstage DHGE', style: AppTextStyles.subheading(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Login',
                style: AppTextStyles.heading(context).copyWith(fontSize: 28),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _studentIdController,
                decoration: InputDecoration(
                  labelText: 'Studenten-ID',
                  labelStyle: AppTextStyles.body(context),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  filled: true,
                  fillColor: AppColors.backgroundSubtle(context),
                ),
                style: AppTextStyles.body(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  labelStyle: AppTextStyles.body(context),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  filled: true,
                  fillColor: AppColors.backgroundSubtle(context),
                ),
                style: AppTextStyles.body(context),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoggingIn ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: AppTextStyles.button(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoggingIn
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
