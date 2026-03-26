import 'package:flutter/material.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  String? hospital;
  String? department;
  String? doctor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          _header(),

          const SizedBox(height: 24),

          _dropdown('Hospital', hospital, ['City Hospital', 'Apollo']),
          const SizedBox(height: 16),

          _dropdown('Department', department, ['General', 'Cardiology']),
          const SizedBox(height: 16),

          _dropdown('Doctor', doctor, ['Dr. Sharma', 'Dr. Reddy']),

          const SizedBox(height: 30),

          _button(),
        ],
      ),
    );
  }

  Widget _header() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'Book Appointment',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );

  Widget _dropdown(String label, String? value, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _card(),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(label),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {
          setState(() {
            if (label == 'Hospital') hospital = val;
            if (label == 'Department') department = val;
            if (label == 'Doctor') doctor = val;
          });
        },
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _button() => Container(
        height: 55,
        decoration: _gradient(),
        child: const Center(
          child: Text('Confirm Booking',
              style: TextStyle(color: Colors.white)),
        ),
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      );

  BoxDecoration _gradient() => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
        ),
        borderRadius: BorderRadius.circular(18),
      );
}