import 'package:flutter/material.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/book_appointment_screen.dart';
import 'screens/my_appointments_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/qr_scanner_screen.dart';

import 'screens/main_navigation.dart';

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
  brightness: Brightness.light,
  primaryColor: const Color(0xFF4A6CF7),

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4A6CF7),
  ),

  scaffoldBackgroundColor: const Color(0xFFF5F7FF),

  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
),

      home: const MainNavigation(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/book': (context) => const BookAppointmentScreen(),
        '/appointments': (context) => const MyAppointmentsScreen(),
        '/queue': (context) => const QueueScreen(),
        '/scan': (context) => const QrScannerScreen(),
      },
    );
  }
}