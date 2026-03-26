import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // 🔥 BIG TOKEN CARD
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Text('Now Serving',
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 10),
                Text(
                  '#3',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          CustomCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatBox('Your Token', '#7'),
                _StatBox('Ahead', '3'),
                _StatBox('Wait', '30m'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('Queue',
              style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          ...['Rahul', 'Anita', 'Kiran'].map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CustomCard(
                  child: Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 10),
                      Text(e),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;

  const _StatBox(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}