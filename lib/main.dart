import 'package:flutter/material.dart';
import 'firebase/firebase_services.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/app_styles.dart';
import 'constants/app_colors.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Backstage DHGE - Choose Module App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundMain(context),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: AppColors.card(context),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
        ),
        textTheme: TextTheme(
          bodyMedium: AppTextStyles.body(context),
          titleMedium: AppTextStyles.subheading(context),
        ),
        dividerColor: Colors.transparent,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundMain(context),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary(context),
        ),
        cardTheme: CardThemeData(
          color: AppColors.card(context),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
        ),
        textTheme: TextTheme(
          bodyMedium: AppTextStyles.body(context),
          titleMedium: AppTextStyles.subheading(context),
        ),
        dividerColor: Colors.transparent,
      ),
      themeMode: ThemeMode.system, // автоматически выбирает светлую или тёмную
      home: const LoginScreen(),
      routes: {
        '/home': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return HomeScreen(
            student: args['student'],
            allModules: args['allModules'],
          );
        },
      },
    );
  }
}
