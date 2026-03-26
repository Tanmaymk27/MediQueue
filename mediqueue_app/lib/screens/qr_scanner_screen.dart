import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {

  bool scanned = false;
  String scannedData = '';

  void _simulateScan() {
    // 🔹 Simulate QR data
    setState(() {
      scanned = true;
      scannedData = 'mediqueue://checkin?appointmentId=123';
    });

    // 🔹 Show result
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Scanned Successfully')),
    );
  }

  void _handleCheckin() {
    // 🔹 Simulate check-in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checked-in! Queue updated')),
    );

    // Navigate to queue screen
    Navigator.pushNamed(context, '/queue');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // 🔥 Scanner Box UI
            CustomCard(
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Camera Preview (Demo)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 Scan Button
            CustomButton(
              text: 'Scan QR',
              icon: Icons.qr_code_scanner,
              onPressed: _simulateScan,
            ),

            const SizedBox(height: 20),

            // 🔥 Scan Result
            if (scanned)
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scanned Data:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(scannedData),

                    const SizedBox(height: 16),

                    CustomButton(
                      text: 'Check In',
                      icon: Icons.login,
                      onPressed: _handleCheckin,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}