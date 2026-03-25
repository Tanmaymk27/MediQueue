import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/hospital.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../services/hospital_service.dart';
import '../services/appointment_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  // Step tracking
  int _currentStep = 0;

  // Data
  List<HospitalModel> _hospitals = [];
  List<String> _departments = [];
  List<DoctorModel> _doctors = [];

  // Selections
  HospitalModel? _selectedHospital;
  String? _selectedDepartment;
  DoctorModel? _selectedDoctor;
  String _appointmentType = 'normal';

  // State
  bool _isLoading = false;
  String? _error;
  AppointmentModel? _bookedAppointment;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    setState(() => _isLoading = true);
    try {
      final hospitals = await HospitalService.getHospitals();
      setState(() => _hospitals = hospitals);
    } catch (e) {
      setState(() => _error = 'Failed to load hospitals');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadDepartments(String hospitalId) async {
    setState(() => _isLoading = true);
    try {
      final departments = await HospitalService.getDepartments(hospitalId);
      setState(() => _departments = departments);
    } catch (e) {
      setState(() => _error = 'Failed to load departments');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadDoctors(String hospitalId, String department) async {
    setState(() => _isLoading = true);
    try {
      final doctors = await HospitalService.getDoctors(
        hospitalId: hospitalId,
        department: department,
      );
      setState(() => _doctors = doctors);
    } catch (e) {
      setState(() => _error = 'Failed to load doctors');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _bookAppointment() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final appointment = await AppointmentService.bookAppointment(
        doctorId:   _selectedDoctor!.id,
        hospitalId: _selectedHospital!.id,
        department: _selectedDepartment!,
        type:       _appointmentType,
      );
      setState(() {
        _bookedAppointment = appointment;
        _currentStep = 4; // success step
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4f8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Appointment',
          style: TextStyle(color: Color(0xFF1a1a2e), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentStep > 0 && _currentStep < 4) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _bookedAppointment != null
          ? _buildSuccessScreen()
          : Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildCurrentStep(),
                ),
              ],
            ),
    );
  }

  // Step indicator at top
  Widget _buildStepIndicator() {
    final steps = ['Hospital', 'Department', 'Doctor', 'Confirm'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive   = i == _currentStep;
          final isComplete = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isComplete
                            ? const Color(0xFF34a853)
                            : isActive
                                ? const Color(0xFF1a73e8)
                                : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isComplete
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.white : Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? const Color(0xFF1a73e8) : Colors.grey,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: isComplete
                          ? const Color(0xFF34a853)
                          : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildHospitalStep();
      case 1: return _buildDepartmentStep();
      case 2: return _buildDoctorStep();
      case 3: return _buildConfirmStep();
      default: return const SizedBox();
    }
  }

  // Step 1 — Hospital
  Widget _buildHospitalStep() {
    return _buildSelectionList(
      title: 'Select Hospital',
      subtitle: 'Choose the hospital you want to visit',
      icon: Icons.local_hospital,
      items: _hospitals.map((h) => _SelectionItem(
        id: h.id,
        title: h.name,
        subtitle: h.address,
      )).toList(),
      onSelect: (id) {
        final hospital = _hospitals.firstWhere((h) => h.id == id);
        setState(() {
          _selectedHospital = hospital;
          _currentStep = 1;
        });
        _loadDepartments(id);
      },
    );
  }

  // Step 2 — Department
  Widget _buildDepartmentStep() {
    return _buildSelectionList(
      title: 'Select Department',
      subtitle: 'Choose the department you need',
      icon: Icons.medical_services_outlined,
      items: _departments.map((d) => _SelectionItem(
        id: d,
        title: d,
        subtitle: '',
      )).toList(),
      onSelect: (dept) {
        setState(() {
          _selectedDepartment = dept;
          _currentStep = 2;
        });
        _loadDoctors(_selectedHospital!.id, dept);
      },
    );
  }

  // Step 3 — Doctor
  Widget _buildDoctorStep() {
    return _buildSelectionList(
      title: 'Select Doctor',
      subtitle: 'Choose your preferred doctor',
      icon: Icons.person_outlined,
      items: _doctors.map((d) => _SelectionItem(
        id: d.id,
        title: 'Dr. ${d.name}',
        subtitle: '~${d.avgConsultationTime} min per patient',
      )).toList(),
      onSelect: (id) {
        final doctor = _doctors.firstWhere((d) => d.id == id);
        setState(() {
          _selectedDoctor = doctor;
          _currentStep = 3;
        });
      },
    );
  }

  // Reusable selection list
  Widget _buildSelectionList({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<_SelectionItem> items,
    required Function(String) onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No items found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () => onSelect(item.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1a73e8).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: const Color(0xFF1a73e8), size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (item.subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Step 4 — Confirm
  Widget _buildConfirmStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm Booking',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review your appointment details',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _SummaryRow(
                  icon: Icons.local_hospital,
                  label: 'Hospital',
                  value: _selectedHospital!.name,
                ),
                const Divider(height: 24),
                _SummaryRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Department',
                  value: _selectedDepartment!,
                ),
                const Divider(height: 24),
                _SummaryRow(
                  icon: Icons.person_outlined,
                  label: 'Doctor',
                  value: _selectedDoctor!.name,
                ),
                const Divider(height: 24),
                _SummaryRow(
                  icon: Icons.timer_outlined,
                  label: 'Avg. time',
                  value: '${_selectedDoctor!.avgConsultationTime} min/patient',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appointment type
          const Text(
            'Appointment Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _appointmentType = 'normal'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _appointmentType == 'normal'
                          ? const Color(0xFF1a73e8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _appointmentType == 'normal'
                            ? const Color(0xFF1a73e8)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person,
                          color: _appointmentType == 'normal'
                              ? Colors.white
                              : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Normal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _appointmentType == 'normal'
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _appointmentType = 'emergency'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _appointmentType == 'emergency'
                          ? const Color(0xFFe53935)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _appointmentType == 'emergency'
                            ? const Color(0xFFe53935)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emergency,
                          color: _appointmentType == 'emergency'
                              ? Colors.white
                              : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Emergency',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _appointmentType == 'emergency'
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _bookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a73e8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Confirm Booking',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Success screen after booking
  Widget _buildSuccessScreen() {
    final apt = _bookedAppointment!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Success icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF34a853).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF34a853),
              size: 64,
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Booking Confirmed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your appointment has been booked',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),

          const SizedBox(height: 32),

          // Token number
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1a73e8), Color(0xFF0d47a1)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Your Token Number',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '#${apt.tokenNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: apt.type == 'emergency'
                        ? Colors.red.shade400
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    apt.type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // QR Code
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Scan at cabin door',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Show this QR when your turn arrives',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: apt.checkinUrl ??
                      'mediqueue://checkin?appointmentId=${apt.id}',
                  version: QrVersions.auto,
                  size: 200,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Wait time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Text(
                  'Estimated wait: ${apt.estimatedWaitTime} minutes',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go Home'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/appointments'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a73e8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('My Appointments'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper classes
class _SelectionItem {
  final String id;
  final String title;
  final String subtitle;
  _SelectionItem({required this.id, required this.title, required this.subtitle});
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1a73e8), size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}