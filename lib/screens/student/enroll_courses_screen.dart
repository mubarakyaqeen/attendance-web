import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/course_model.dart';
import '../../service/student_service.dart';


class EnrollCoursesScreen extends StatefulWidget {
  const EnrollCoursesScreen({super.key});

  @override
  State<EnrollCoursesScreen> createState() => _EnrollCoursesScreenState();
}

class _EnrollCoursesScreenState extends State<EnrollCoursesScreen> {

  List<Course> courses = [];
  bool loading = true;

  int? userId;
  String? token;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getInt("userId");
    token = prefs.getString("token");

    final data = await StudentService.getCourses(userId!, token!);
    setState(() {
      courses = data;
      loading = false;
    });
  }




  Future<void> enroll(int courseId) async {

    await StudentService.enrollCourse(userId!, courseId, token!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enrolled successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(title: const Text("Enroll Courses")),

      body: ListView(

        children: courses.map((course) {

          return ListTile(

            title: Text("${course.code} - ${course.name}"),

            trailing: ElevatedButton(
              onPressed: () => enroll(course.id),
              child: const Text("Enroll"),
            ),
          );

        }).toList(),
      ),
    );
  }
}