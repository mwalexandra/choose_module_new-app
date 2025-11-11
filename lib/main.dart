import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'constants/app_colors.dart';
import 'models/student.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ChooseModuleApp());
}

class ChooseModuleApp extends StatelessWidget {
  const ChooseModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backstage DHGE - WPM App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');

        // --- Die erste Seite (Login) ---
        if (uri.path == '/' || uri.path.isEmpty) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }

        // --- Pfad /home/<studentId> ---
        if (uri.path == '/home') {
          final args = settings.arguments as Map<String, dynamic>?;
          final student = args?['student'] as Student?;
          if (student != null) {
            return MaterialPageRoute(
              builder: (_) => HomeScreen(student: student),
            );
          }
        }
        // --- fallback ---
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      },
    );
  }
}
