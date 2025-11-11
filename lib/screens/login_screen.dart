import 'package:flutter/material.dart';
import '../firebase/firebase_services.dart';
import '../models/student.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';
import '../utils/url_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Map<String, String> urlParams = {};

  @override
  void initState() {
    super.initState();
    // URL-Parameter abrufen (nur Web)
    urlParams = getUrlParameters();

    // Falls URL-Parameter vorhanden, Felder ausfüllen
    if (urlParams.isNotEmpty) {
      _idController.text = urlParams['login'] ?? '';
      _passwordController.text = ''; // Passwort kann leer bleiben
    }
  }

  Future<void> _login() async {
    String studentId = _idController.text.trim();
    String password = _passwordController.text.trim();

    // Falls URL-Parameter vorhanden, verwenden wir diese
    if (urlParams.isNotEmpty) {
      studentId = urlParams['login'] ?? studentId;
      password = urlParams['password'] ?? password;
    }

    if (studentId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Student-ID und Passwort eingeben')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Studenten-Daten aus Firebase laden
      final studentsData = await FirebaseServices.getStudents();

      if (!studentsData.containsKey(studentId)) {
        throw 'Student nicht gefunden';
      }

      final studentMap = Map<String, dynamic>.from(studentsData[studentId]);

      if (studentMap['password'] != password) {
        throw 'Falsches Passwort';
      }

      // Alle Module laden
      final allModules = await FirebaseServices.getModules();

      // Student-Objekt erstellen und name/email aus URL aktualisieren
      final student = Student.fromMap(studentId, studentMap, allModules).copyWith(
        name: urlParams['name'] ?? studentMap['name'] ?? '',
        email: urlParams['email'] ?? studentMap['email'] ?? '',
      );

      // Navigation zum HomeScreen
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
              Text('Login', style: AppTextStyles.heading(context)),
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(color: Colors.white)),
                ),
              ),
              if (urlParams.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Willkommen, ${urlParams['name'] ?? 'Student'}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
