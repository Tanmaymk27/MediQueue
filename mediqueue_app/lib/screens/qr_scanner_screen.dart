import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'queue_screen.dart';
import 'book_appointment_screen.dart';
import 'dart:convert';
import '../config/api.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // --- Logic State ---
  String? scannedData;
  bool scanned = false;
  bool isUpdatingQueue = false;

  // --- UI Constants ---
  static const _bg = Color(0xFFF0F4FF);
  static const _primary = Color(0xFF2563EB);
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  // --- QR Code Type Detection ---
  Map<String, String> _parseQrCodeParameters(String data) {
    final params = <String, String>{};
    String normalized = data.trim();

    if (normalized.contains('?')) {
      normalized = normalized.split('?').last;
    }

    for (final part in normalized.split('&')) {
      if (!part.contains('=')) continue;
      final index = part.indexOf('=');
      final key = part.substring(0, index).trim().toLowerCase();
      final value = Uri.decodeComponent(part.substring(index + 1).trim());
      if (key.isNotEmpty) {
        params[key] = value;
      }
    }

    return params;
  }

  String _getQrCodeType(String data) {
    final params = _parseQrCodeParameters(data);

    final hasAppointmentFields = params.containsKey('id') ||
        params.containsKey('patient') ||
        params.containsKey('token');
    final hasDoctorFields = params.containsKey('doctor') && params.containsKey('department');
    final hasHospitalField = params.containsKey('hospital');

    if (hasAppointmentFields) return 'appointment';
    if (hasDoctorFields) return 'doctor_cabin';
    if (hasHospitalField) return 'hospital';

    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildScannerViewfinder(),
                    const SizedBox(height: 28),
                    
                    // Toggle between Result Card and Instructions
                    scanned ? _buildResultCard() : _buildInstructions(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Scan QR Code',
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w800, 
              color: _ink, 
              letterSpacing: -0.5
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Point your camera at the QR code to check in', 
            style: TextStyle(fontSize: 13, color: _muted)
          ),
        ],
      ),
    );
  }

  Widget _buildScannerViewfinder() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // LIVE CAMERA
            MobileScanner(
              onDetect: (capture) {
                if (scanned) return;
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final String? code = barcode.rawValue;
                  if (code != null) {
                    setState(() {
                      scannedData = code;
                      scanned = true;
                    });
                  }
                }
              },
            ),

            // Corner brackets
            Positioned(top: 28, left: 28, child: _Corner(rotate: 0)),
            Positioned(top: 28, right: 28, child: _Corner(rotate: 1)),
            Positioned(bottom: 28, left: 28, child: _Corner(rotate: 3)),
            Positioned(bottom: 28, right: 28, child: _Corner(rotate: 2)),

            // Scan Line
            if (!scanned)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, _primary.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                ),
              ),
              
            // Success Overlay
            if (scanned)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline_rounded, color: _primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Scan the QR code from your appointment confirmation to check in at the cabin.',
                  style: TextStyle(fontSize: 13, color: _muted, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _ScanStep(number: '1', text: 'Open your appointment confirmation'),
        const SizedBox(height: 10),
        const _ScanStep(number: '2', text: 'Point camera at the QR code'),
        const SizedBox(height: 10),
        const _ScanStep(number: '3', text: 'Wait for the system to verify'),
      ],
    );
  }

  Widget _buildResultCard() {
    if (scannedData == null) return const SizedBox();

    final qrType = _getQrCodeType(scannedData!);

    switch (qrType) {
      case 'appointment':
        return _buildAppointmentResultCard();
      case 'hospital':
        return _buildHospitalResultCard();
      case 'doctor_cabin':
        return _buildDoctorCabinResultCard();
      default:
        return _buildUnknownResultCard();
    }
  }

  Widget _buildAppointmentResultCard() {
    final params = _parseQrCodeParameters(scannedData!);
    final id = params['id'] ?? '';
    final patient = params['patient'] ?? 'Guest';
    final doctor = params['doctor'] ?? 'Verified';
    final hospital = params['hospital'] ?? 'System';
    final department = params['department'] ?? '';
    final token = params['token'] ?? '00';
    final date = params['date'] ?? '';
    final phone = params['phone'] ?? '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Patient Verified ✅', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _ink)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('#$token', style: const TextStyle(color: _primary, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          _resultRow(Icons.person, 'Patient', patient),
          const SizedBox(height: 12),
          _resultRow(Icons.medical_services, 'Doctor', doctor),
          const SizedBox(height: 12),
          _resultRow(Icons.business_rounded, 'Hospital', hospital),
          const SizedBox(height: 12),
          _resultRow(Icons.local_hospital, 'Department', department),
          const SizedBox(height: 12),
          _resultRow(Icons.calendar_today, 'Date', date),
          const SizedBox(height: 12),
          _resultRow(Icons.phone, 'Phone', phone),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _muted.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: isUpdatingQueue ? null : () => _handleQueueUpdate(),
                  child: isUpdatingQueue
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Add to Queue', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: isUpdatingQueue ? null : () => setState(() { scanned = false; scannedData = null; }),
                icon: const Icon(Icons.refresh_rounded, color: _muted),
                style: IconButton.styleFrom(
                  backgroundColor: _bg,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHospitalResultCard() {
    final params = _parseQrCodeParameters(scannedData!);
    final hospital = params['hospital'] ?? 'Unknown Hospital';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.local_hospital, size: 48, color: _primary),
          const SizedBox(height: 16),
          Text('Hospital Reception', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _ink)),
          const SizedBox(height: 8),
          Text(hospital, style: TextStyle(fontSize: 16, color: _muted)),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => _navigateToBookAppointment(hospital),
                  child: const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => setState(() { scanned = false; scannedData = null; }),
                icon: const Icon(Icons.refresh_rounded, color: _muted),
                style: IconButton.styleFrom(
                  backgroundColor: _bg,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDoctorCabinResultCard() {
    final params = _parseQrCodeParameters(scannedData!);
    final doctor = params['doctor'] ?? 'Unknown Doctor';
    final department = params['department'] ?? 'Unknown Department';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.medical_services, size: 48, color: _primary),
          const SizedBox(height: 16),
          Text('Doctor Cabin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _ink)),
          const SizedBox(height: 8),
          Text(doctor, style: TextStyle(fontSize: 16, color: _muted)),
          Text(department, style: TextStyle(fontSize: 14, color: _muted.withOpacity(0.7))),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _muted.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: isUpdatingQueue ? null : () => _handleDoctorCabinQueueUpdate(),
                  child: isUpdatingQueue
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Update Queue', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: isUpdatingQueue ? null : () => setState(() { scanned = false; scannedData = null; }),
                icon: const Icon(Icons.refresh_rounded, color: _muted),
                style: IconButton.styleFrom(
                  backgroundColor: _bg,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUnknownResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('Unknown QR Code', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _ink)),
          const SizedBox(height: 8),
          const Text('This QR code is not recognized by the system', style: TextStyle(fontSize: 14, color: _muted)),
          const SizedBox(height: 24),

          IconButton(
            onPressed: () => setState(() { scanned = false; scannedData = null; }),
            icon: const Icon(Icons.refresh_rounded, color: _muted),
            style: IconButton.styleFrom(
              backgroundColor: _bg,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  // --- 🔥 UPDATED ASYNC LOGIC WITH REAL HTTP POST ---
  void _handleQueueUpdate() async {
    setState(() => isUpdatingQueue = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating Queue...'), duration: Duration(milliseconds: 800)),
    );

    // Re-parse data to get the MongoDB ID
    final params = _parseQrCodeParameters(scannedData!);
    String appointmentId = params['id'] ?? '';

    // Fallback if the QR code is just the raw ID string
    if (!scannedData!.contains('=')) {
      appointmentId = scannedData!;
    }

    if (appointmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text('Invalid QR format. Missing ID.')),
      );
      setState(() => isUpdatingQueue = false);
      return;
    }

    try {
      // 🚀 REAL API CALL TO YOUR BACKEND
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/queue/update/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'serving'}),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('Patient Added to Queue ✅')),
        );

        // Navigate to the Queue Screen
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const QueueScreen(isScanned: true))
        );
      } else {
        throw Exception('Failed to update queue: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.red, content: Text('Failed to update queue ❌')),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdatingQueue = false);
    }
  }

  void _navigateToBookAppointment(String hospitalName) {
    // Navigate to book appointment screen with pre-selected hospital
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(preSelectedHospital: hospitalName),
      ),
    );
  }

  void _handleDoctorCabinQueueUpdate() async {
    setState(() => isUpdatingQueue = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating Doctor Queue...'), duration: Duration(milliseconds: 800)),
    );

    // Parse doctor and department from QR data
    final params = _parseQrCodeParameters(scannedData!);
    final doctor = params['doctor'] ?? '';
    final department = params['department'] ?? '';

    if (doctor.isEmpty || department.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text('Invalid doctor cabin QR format.')),
      );
      setState(() => isUpdatingQueue = false);
      return;
    }

    try {
      // API call to update doctor cabin queue
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/queue/doctor-cabin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'doctor': doctor,
          'department': department,
          'action': 'next_patient'
        }),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('Doctor Queue Updated ✅')),
        );

        // Navigate to queue screen or stay on scanner
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QueueScreen(isScanned: true))
        );
      } else {
        throw Exception('Failed to update doctor queue: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.red, content: Text('Failed to update doctor queue ❌')),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdatingQueue = false);
    }
  }

  Widget _resultRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _muted),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: _muted, fontSize: 14)),
        Expanded(child: Text(value, style: const TextStyle(color: _ink, fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

// --- Custom Components ---

class _Corner extends StatelessWidget {
  final int rotate;
  const _Corner({required this.rotate});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotate * 1.5708,
      child: SizedBox(
        width: 24, height: 24,
        child: CustomPaint(painter: _CornerPainter()),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanStep extends StatelessWidget {
  final String number, text;
  const _ScanStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26, height: 26,
          decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
          child: Center(
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
      ],
    );
  }
}