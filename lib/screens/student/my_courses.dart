import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service/student_service.dart';
import 'course_details_screen.dart';
import 'enroll_courses_screen.dart';

class MyCourses extends StatefulWidget {
  const MyCourses({super.key});

  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {

  List<String> courses = [];
  bool loading = true;
  String? error;

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  /*
  =====================================
  FETCH COURSES FROM BACKEND
  =====================================
  */

  Future<void> fetchCourses() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt("userId");
      final token = prefs.getString("token");

      if (userId == null || token == null) {
        throw Exception("User session not found");
      }

      final data =
      await StudentService.getDashboard(userId, token);

      safeSetState(() {
        courses = data.courses;
        loading = false;
        error = null;
      });

    } catch (e) {

      safeSetState(() {
        error = e.toString();
        loading = false;
      });

    }
  }


  // Future<void> fetchCourses() async {
  //
  //   try {
  //
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     final userId = prefs.getInt("userId");
  //     final token = prefs.getString("token");
  //
  //     if (userId == null || token == null) {
  //       throw Exception("User session not found");
  //     }
  //
  //     final data =
  //     await StudentService.getDashboard(userId, token);
  //
  //     setState(() {
  //       courses = data.courses;
  //       loading = false;
  //       error = null;
  //     });
  //
  //   } catch (e) {
  //
  //     setState(() {
  //       error = e.toString();
  //       loading = false;
  //     });
  //
  //   }
  // }

  /*
  =====================================
  UI
  =====================================
  */

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Courses"),
        backgroundColor: const Color(0xFF034D08),

        /*
        Refresh button
        */
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCourses,
          )
        ],
      ),

      /*
      =====================================
      BODY WITH PULL TO REFRESH
      =====================================
      */

      body: RefreshIndicator(

        onRefresh: fetchCourses,

        child: Column(

          children: [

            /*
            =====================================
            ENROLL BUTTON
            =====================================
            */

            Padding(
              padding: const EdgeInsets.all(12),

              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A300),
                  ),

                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnrollCoursesScreen(),
                      ),
                    ).then((_) {
                      if (!mounted) return;
                      fetchCourses();
                    });

                  },

                  icon: const Icon(Icons.add, color: Colors.white),

                  label: const Text(
                    "Enroll New Course",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            /*
            =====================================
            COURSE LIST
            =====================================
            */

            Expanded(

              child: courses.isEmpty

                  ? const Center(
                child: Text("No courses found"),
              )

                  : ListView(

                children: courses.map((course) {

                  /*
                        Split:
                        CODE - TITLE - LECTURER
                        */

                  final parts = course.split(" - ");

                  final code = parts.isNotEmpty ? parts[0] : "";
                  final title = parts.length > 1 ? parts[1] : "";
                  final lecturer =
                  parts.length > 2 ? parts[2] : "Unknown";

                  return Card(

                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),

                    child: ListTile(

                      leading: const Icon(
                        Icons.book,
                        color: Color(0xFF034D08),
                        size: 32,
                      ),

                      title: Text(
                        "$code - $title",
                        style: const TextStyle(
                          color: Color(0xFF034D08),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      subtitle: Text(
                        "Lecturer: $lecturer",
                        style: const TextStyle(
                          color: Color(0xFFF4A300),
                          fontSize: 14,
                        ),
                      ),

                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                      /*
                            NAVIGATION TO COURSE DETAILS
                            */

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) => CourseDetailsScreen(
                              courseCode: code,
                              courseTitle: title,
                              lecturerName: lecturer,
                            ),

                          ),
                        );
                      },
                    ),
                  );

                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}