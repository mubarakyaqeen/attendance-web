import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/attendance_history_model.dart';
import '../models/course_model.dart';
import '../models/department_model.dart';
import '../models/student_dashboard_model.dart';
import '../models/student_profile_model.dart';
import '../utils/api_constants.dart';


class StudentService {

  /*
  =========================
  FETCH DEPARTMENTS
  =========================
  */

  static Future<List<Department>> getDepartments() async {

    final response = await http.get(
      Uri.parse(ApiConstants.departments),
    );

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data.map((dept) => Department.fromJson(dept)).toList();

    } else {

      throw Exception("Failed to load departments");

    }
  }

  /*
  =========================
  REGISTER STUDENT
  =========================
  */

  static Future<void> registerStudent({

    required String fullName,
    required String matricNumber,
    required String email,
    required String password,
    required int departmentId,
    required String level,

  }) async {

    final response = await http.post(

      Uri.parse(ApiConstants.createStudent),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "fullName": fullName,
        "matricNumber": matricNumber,
        "email": email,
        "password": password,
        "departmentId": departmentId,
        "level": level,

      }),

    );

    /// ✅ IMPORTANT FIX HERE
    if (response.statusCode != 200 && response.statusCode != 201) {

      /// 🔥 Pass backend error directly (VERY IMPORTANT)
      throw Exception(response.body);

    }
  }

  /*
  =========================
  STUDENT DASHBOARD
  =========================
  */

  static Future<StudentDashboardModel> getDashboard(
      int userId,
      String token,
      ) async {

    final response = await http.get(

      Uri.parse("${ApiConstants.studentDashboard}/$userId"),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },

    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return StudentDashboardModel.fromJson(data);

    } else {

      throw Exception("Failed to load dashboard");

    }
  }

  /*
=========================
GET COURSES
=========================
*/

  /*
=========================
GET FILTERED COURSES
=========================
*/

  static Future<List<Course>> getCourses(
      int userId,
      String token,
      ) async {

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/student/courses/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data.map((e) => Course.fromJson(e)).toList();

    } else {
      throw Exception("Failed to load courses");
    }
  }

/*
=========================
ENROLL COURSE
=========================
*/

  static Future<void> enrollCourse(
      int userId,
      int courseId,
      String token,
      ) async {

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/student/enroll?userId=$userId&courseId=$courseId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Enrollment failed");
    }
  }

  /*
=========================
GET ATTENDANCE HISTORY
=========================
*/

  static Future<List<AttendanceHistoryModel>> getAttendanceHistory(
      int userId,
      String token,
      ) async {

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/student/attendance/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data.map((e) => AttendanceHistoryModel.fromJson(e)).toList();

    } else {
      throw Exception("Failed to load attendance history");
    }
  }


  static Future<StudentProfileModel> getProfile(
      int userId,
      String token,
      ) async {

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/student/profile/$userId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return StudentProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load profile");
    }
  }



  static Future<void> updateProfileImage(
      int userId,
      String imageUrl,
      String token,
      ) async {

    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/student/profile/image"),
      headers: {
        "Authorization": "Bearer $token",
      },
      body: {
        "userId": userId.toString(),
        "imageUrl": imageUrl,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update image");
    }
  }


  static Future<String> uploadProfileImage(
      int userId,
      File file,
      String token,
      ) async {

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConstants.baseUrl}/student/profile/upload"),
    );

    request.headers['Authorization'] = "Bearer $token";

    request.fields['userId'] = userId.toString();

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    var response = await request.send();

    final responseBody = await response.stream.bytesToString();

    print("UPLOAD STATUS: ${response.statusCode}");
    print("UPLOAD RESPONSE: $responseBody");

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception("Upload failed: $responseBody");
    }
  }


  static Future<void> markAttendance({
    required int userId,
    required int courseId,
    required String token,
    required double latitude,
    required double longitude,
  }) async {

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/student/mark-attendance"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userId": userId,
        "courseId": courseId,
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to mark attendance");
    }
  }

  static Future<Map<String, dynamic>> markAttendanceV2({
    required int studentId,
    required int sessionId,
    required String token,
    required double latitude,
    required double longitude,
  }) async {

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/student/mark-attendance-v2"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "studentId": studentId,
        "sessionId": sessionId,
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    print("📡 STATUS: ${response.statusCode}");
    print("📦 BODY: ${response.body}");

    // ❌ ERROR CASE
    if (response.statusCode != 200) {
      throw Exception(
        response.body.isEmpty
            ? "Failed to mark attendance"
            : response.body,
      );
    }



    // ✅ SUCCESS CASE
    if (response.body.isEmpty) {
      return {"message": "Attendance marked successfully"};
    }

    return jsonDecode(response.body);
  }


  static Future<int> getActiveSessionId({
    required int courseId,
    required String token,
  }) async {

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/student/active-session?courseId=$courseId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["id"]; // 👈 sessionId
    } else {
      throw Exception("No active session");
    }
  }

  static Future<Map<String, dynamic>> getLatestAttendance(
      int userId,
      String token,
      ) async {

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/student/attendance/latest/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch attendance");
    }
  }




}