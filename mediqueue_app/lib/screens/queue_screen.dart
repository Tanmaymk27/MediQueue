import 'package:flutter/material.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {

  Map<String, dynamic>? selectedAppointment;

  final appointments = [
    {
      'doctor': 'Dr. Sharma',
      'hospital': 'City Hospital',
      'token': 7,
    },
    {
      'doctor': 'Dr. Reddy',
      'hospital': 'Apollo Clinic',
      'token': 3,
    },
  ];

  final queue = [
    {'token': 4, 'name': 'Rahul'},
    {'token': 5, 'name': 'Anita'},
    {'token': 6, 'name': 'Kiran'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: selectedAppointment == null
            ? _buildAppointmentSelector()
            : _buildQueueView(),
      ),
    );
  }

  // 🔥 SELECT APPOINTMENT
  Widget _buildAppointmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'Select Appointment',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        ...appointments.map((apt) => GestureDetector(
          onTap: () {
            setState(() {
              selectedAppointment = apt;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apt['doctor'].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  apt['hospital'].toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ))
      ],
    );
  }

  // 🔥 QUEUE VIEW
  Widget _buildQueueView() {

    int currentToken = 3;
    int yourToken = selectedAppointment!['token'];

    int ahead = yourToken - currentToken - 1;

    return Column(
      children: [

        // 🔙 BACK
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              setState(() {
                selectedAppointment = null;
              });
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),

        const SizedBox(height: 10),

        // 🔥 HEADER
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                selectedAppointment!['doctor'].toString(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                selectedAppointment!['hospital'].toString(),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 🔥 NOW SERVING
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text('Now Serving'),
              const SizedBox(height: 8),
              Text(
                '#$currentToken',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6CF7),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 🔥 STATUS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _infoBox('Your Token', '#$yourToken'),
            _infoBox('Ahead', '$ahead'),
            _infoBox('Wait', '${ahead * 10} min'),
          ],
        ),

        const SizedBox(height: 20),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Queue List',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 10),

        // 🔥 QUEUE LIST
        Expanded(
          child: ListView.builder(
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final person = queue[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        '#${person['token'].toString()}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(person['name'].toString()),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _infoBox(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}