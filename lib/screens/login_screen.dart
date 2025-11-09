import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';
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

  Map<String, dynamic> students = {};
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
      students = deepConvertMap(Map<Object?, Object?>.from(studentData));
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

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final studentId = _studentIdController.text.trim();
    final password = _passwordController.text;

    final student = students[studentId];
    if (student == null) {
      _showError('Студент не найден');
      return;
    }

    if (student['password'] != password) {
      _showError('Неверный пароль');
      return;
    }

    setState(() => isLoggingIn = true);

    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            student: {'id': studentId, ...student},
            allModules: allModules,
          ),
        ),
      );
    } catch (e) {
      _showError('Ошибка при входе');
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
      appBar: AppBar(title: const Text('Login')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose Module App',
                      style: AppTextStyles.heading().copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _studentIdController,
                      decoration: InputDecoration(
                        labelText: 'Student ID',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      ),
                      style: AppTextStyles.body().copyWith(fontSize: 18),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Введите Student ID' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      ),
                      style: AppTextStyles.body().copyWith(fontSize: 18),
                      obscureText: true,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Введите пароль' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoggingIn ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoggingIn
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('Login', style: AppTextStyles.body().copyWith(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
