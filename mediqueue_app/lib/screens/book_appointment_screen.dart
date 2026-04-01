import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ─── TOKEN SCREEN ──────────────────────────────────────────────────────────

class TokenScreen extends StatelessWidget {
  final String doctor;
  final String hospital;
  final String department;
  final int token;

  const TokenScreen({
    super.key,
    required this.doctor,
    required this.hospital,
    required this.department,
    required this.token,
  });

  // UI Constants
  static const _primary = Color(0xFF2563EB);
  static const _bg = Color(0xFFF0F4FF);
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 🔥 HEADER CARD (Token Display)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primary, Color(0xFF6A8DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('Registration Successful', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    const Text('YOUR TOKEN', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    Text(
                      '#$token',
                      style: const TextStyle(color: Colors.white, fontSize: 68, fontWeight: FontWeight.w900, letterSpacing: -2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔥 DETAILS CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _row('Doctor', doctor, Icons.person_outline_rounded),
                    const Divider(height: 28, color: Color(0xFFF1F5F9)),
                    _row('Hospital', hospital, Icons.local_hospital_outlined),
                    const Divider(height: 28, color: Color(0xFFF1F5F9)),
                    _row('Department', department, Icons.medical_services_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔥 QR CODE BOX (Simulation for Scanner)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _primary.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 140, color: _ink),
                      const SizedBox(height: 16),
                      const Text(
                        'SCAN AT RECEPTION',
                        style: TextStyle(color: _muted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data: doctor=$doctor&token=$token',
                        style: TextStyle(color: _muted.withOpacity(0.4), fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔥 DONE BUTTON
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _primary),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: _muted, fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _ink)),
      ],
    );
  }
}

// ─── BOOK APPOINTMENT SCREEN ───────────────────────────────────────────────

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  String? hospital;
  String? department;
  String? doctor;
  bool isBooking = false; // 🔥 Tracks the loading state

  static const _bg = Color(0xFFF0F4FF);
  static const _primary = Color(0xFF2563EB);
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _surface = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _label('Select Hospital'),
                  const SizedBox(height: 8),
                  _buildDropdown('Hospital', hospital, ['City Hospital', 'Apollo'], Icons.local_hospital_outlined),
                  const SizedBox(height: 18),
                  _label('Select Department'),
                  const SizedBox(height: 8),
                  _buildDropdown('Department', department, ['General', 'Cardiology'], Icons.medical_services_outlined),
                  const SizedBox(height: 18),
                  _label('Select Doctor'),
                  const SizedBox(height: 8),
                  _buildDropdown('Doctor', doctor, ['Dr. Sharma', 'Dr. Reddy'], Icons.person_outlined),
                  const SizedBox(height: 36),
                  _buildConfirmButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Book Appointment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -0.8)),
          SizedBox(height: 4),
          Text('Reserve your consultation slot instantly', style: TextStyle(fontSize: 13, color: _muted)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primary.withOpacity(0.1)),
      ),
      child: Row(
        children: const [
          Icon(Icons.bolt_rounded, color: _primary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your digital token will be generated immediately after confirmation.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF1D4ED8), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ink));

  Widget _buildDropdown(String label, String? value, List<String> items, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value != null ? _primary.withOpacity(0.3) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text('Choose $label', style: const TextStyle(fontSize: 14, color: _muted)),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: value != null ? _primary : _muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        icon: const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.expand_more_rounded, color: _muted)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
        onChanged: isBooking ? null : (val) => setState(() {
          if (label == 'Hospital') hospital = val;
          if (label == 'Department') department = val;
          if (label == 'Doctor') doctor = val;
        }),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final bool isReady = hospital != null && department != null && doctor != null && !isBooking;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isReady ? _primary : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(18),
        boxShadow: isReady ? [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))] : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isReady ? _handleBookingFlow : null,
          child: Center(
            child: isBooking
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Confirm & Generate Token', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  // 🔥 THE UPDATED ASYNC LOGIC
  Future<void> _handleBookingFlow() async {
  print("BUTTON CLICKED"); // ✅ debug

  setState(() => isBooking = true);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Processing Appointment...')),
  );

  try {
    print("CALLING API..."); // ✅ debug

    final response = await http.post(
      Uri.parse('http://192.168.0.125:5000/api/appointments'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'doctor': doctor!,
        'hospital': hospital!,
        'department': department!,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TokenScreen(
            doctor: doctor!,
            hospital: hospital!,
            department: department!,
            token: DateTime.now().millisecondsSinceEpoch % 1000,
          ),
        ),
      );
    } else {
      throw Exception("Booking failed");
    }

  } catch (e) {
    print("FULL ERROR: $e"); // 🔥 IMPORTANT

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => isBooking = false);
  }
}
}