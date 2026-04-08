import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/course_model.dart';
import '../utils/api_constants.dart';

class CourseService {

  /*
  =====================================
  GET COURSES FOR A SPECIFIC LECTURER
  =====================================
  */

  static Future<List<Course>> getLecturerCourses(
      int lecturerId,
      String token,
      ) async {

    final response = await http.get(

      Uri.parse("${ApiConstants.createCourse}/lecturer/$lecturerId"),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {

      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((course) => Course.fromJson(course))
          .toList();

    } else {

      throw Exception("Failed to load lecturer courses");

    }
  }

  /*
  =====================================
  GET ALL COURSES
  =====================================
  */

  static Future<List<Course>> getCourses(String token) async {

    final response = await http.get(

      Uri.parse(ApiConstants.createCourse),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },

    );

    if (response.statusCode == 200) {

      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((course) => Course.fromJson(course))
          .toList();

    } else {

      throw Exception("Failed to load courses");

    }
  }

  /*
  =====================================
  CREATE COURSE
  =====================================
  */

  static Future<void> createCourse({
    required String code,
    required String name,
    required int lecturerId,
    required int departmentId,
    required String token,
    required String level,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.createCourse}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "code": code,
        "name": name,
        "lecturerId": lecturerId,
        "departmentId": departmentId,
        "level": level,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  /*
  =====================================
  DELETE COURSE
  =====================================
  */

  static Future<void> deleteCourse({

    required int courseId,
    required String token,

  }) async {

    final response = await http.delete(

      Uri.parse("${ApiConstants.createCourse}/$courseId"),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },

    );

    if (response.statusCode != 200 && response.statusCode != 204) {

      throw Exception("Failed to delete course");

    }
  }



}