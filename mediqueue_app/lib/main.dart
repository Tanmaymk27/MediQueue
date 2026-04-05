import 'package:flutter/material.dart';

// Screens
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MediQueueApp());
}

class MediQueueApp extends StatelessWidget {
  const MediQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediQueue',

      theme: ThemeData(
        primaryColor: const Color(0xFF4A6CF7),
        scaffoldBackgroundColor: const Color(0xFFF5F7FF),
      ),

      // 🚀 START FROM SPLASH TO CHECK AUTH
      home: const SplashScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}