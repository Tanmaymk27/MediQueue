import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // 🔥 HEADER WITH GRADIENT
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Manage your health smartly',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: const [
              _FeatureCard(Icons.calendar_today, 'Book'),
              _FeatureCard(Icons.list_alt, 'Appointments'),
              _FeatureCard(Icons.people, 'Queue'),
              _FeatureCard(Icons.qr_code, 'Scan'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureCard(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Color(0xFF4A6CF7)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}