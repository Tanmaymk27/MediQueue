import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/appointment.dart';
import 'auth_service.dart';

class AppointmentService {
  static Future<AppointmentModel> bookAppointment({
    required String doctorId,
    required String hospitalId,
    required String department,
    required String type,
  }) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse(ApiConfig.appointments),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'doctorId': doctorId,
        'hospitalId': hospitalId,
        'department': department,
        'type': type,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 201) {
      throw Exception(data['message'] ?? 'Booking failed');
    }
    return AppointmentModel.fromJson(data);
  }

  static Future<List<AppointmentModel>> getMyAppointments() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${ApiConfig.appointments}/my'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final List data = jsonDecode(res.body);
    return data.map((a) => AppointmentModel.fromJson(a)).toList();
  }
}