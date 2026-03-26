import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/app_header.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final data = [
      {
        'doctor': 'Dr. Sharma',
        'hospital': 'City Hospital',
        'token': 5,
        'status': 'Waiting'
      },
      {
        'doctor': 'Dr. Reddy',
        'hospital': 'Apollo',
        'token': 2,
        'status': 'Serving'
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            const AppHeader(
              title: 'My Appointments',
              subtitle: 'Track your bookings',
            ),

            const SizedBox(height: 20),

            ...data.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(e['doctor'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 4),

                    Text(e['hospital'] as String,
                        style: const TextStyle(color: Colors.grey)),

                    const SizedBox(height: 10),

                    Text('Token: ${e['token']}'),
                    Text('Status: ${e['status']}'),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}