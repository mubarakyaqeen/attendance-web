import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class DepartmentService {

  static Future<void> createDepartment(String name) async {

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/admin/departments"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create department");
    }
  }
}