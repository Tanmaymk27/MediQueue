import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/hospital.dart';
import '../models/doctor.dart';

class HospitalService {
  static Future<List<HospitalModel>> getHospitals() async {
    final res = await http.get(Uri.parse(ApiConfig.hospitals));
    final List data = jsonDecode(res.body);
    return data.map((h) => HospitalModel.fromJson(h)).toList();
  }

  static Future<List<String>> getDepartments(String hospitalId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.hospitals}/$hospitalId/departments'),
    );
    final data = jsonDecode(res.body);
    return List<String>.from(data['departments']);
  }

  static Future<List<DoctorModel>> getDoctors({
    required String hospitalId,
    required String department,
  }) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.doctors}?hospitalId=$hospitalId&department=${Uri.encodeComponent(department)}'),
    );
    final List data = jsonDecode(res.body);
    return data.map((d) => DoctorModel.fromJson(d)).toList();
  }
}