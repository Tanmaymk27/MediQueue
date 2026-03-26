import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_header.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {

  String? hospital;
  String? department;
  String? doctor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            const AppHeader(
              title: 'Book Appointment',
              subtitle: 'Choose hospital and doctor',
            ),

            const SizedBox(height: 20),

            CustomCard(
              child: DropdownButtonFormField<String>(
                hint: const Text('Select Hospital'),
                value: hospital,
                items: ['City Hospital', 'Apollo']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => hospital = val),
              ),
            ),

            const SizedBox(height: 16),

            CustomCard(
              child: DropdownButtonFormField<String>(
                hint: const Text('Select Department'),
                value: department,
                items: ['General', 'Cardiology']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => department = val),
              ),
            ),

            const SizedBox(height: 16),

            CustomCard(
              child: DropdownButtonFormField<String>(
                hint: const Text('Select Doctor'),
                value: doctor,
                items: ['Dr. Sharma', 'Dr. Reddy']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => doctor = val),
              ),
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: 'Book Now',
              onPressed: doctor == null ? null : () {},
            )
          ],
        ),
      ),
    );
  }
}