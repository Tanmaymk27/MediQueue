import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'book_appointment_screen.dart';
import 'my_appointments_screen.dart';
import 'queue_screen.dart';
import 'qr_scanner_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int currentIndex = 0;

  final screens = [
    const HomeScreen(),
    const BookAppointmentScreen(),
    const MyAppointmentsScreen(),
    const QueueScreen(),
    const QrScannerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          selectedItemColor: const Color(0xFF1a73e8),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Queue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
          ],
        ),
      ),
    );
  }
}