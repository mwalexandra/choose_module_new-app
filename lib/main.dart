import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Choose Module App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,

      // Стартовый экран
      initialRoute: '/login',

      // Именованные маршруты
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) {
          // Мы будем передавать аргументы при переходе
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return HomeScreen(
            studentId: args['studentId'],
            studentData: args['studentData'],
          );
        },
      },
    );
  }
}
