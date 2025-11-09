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
      _showError('Student ID ist nicht gefunden');
      return;
    }

    if (student['password'] != password) {
      _showError('Passwort ist falsch');
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
      _showError('Fehler beim Einloggen');
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
    backgroundColor: AppColors.backgroundMain(context), // добавлено
    appBar: AppBar(
      title: Text('Backstage DHGE', style: AppTextStyles.subheading(context)),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Form(
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          filled: true,
                          fillColor: AppColors.backgroundSubtle(context), // фон поля
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
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
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary, // фон кнопки
                            foregroundColor: Colors.white,      // цвет текста
                            textStyle: AppTextStyles.button(context),  // шрифт, размер, жирность
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
  );
  }
}
