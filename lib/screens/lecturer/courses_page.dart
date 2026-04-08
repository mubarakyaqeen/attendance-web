import 'package:flutter/material.dart';
import 'package:student_attendance_app/models/course_model.dart';
import 'package:student_attendance_app/screens/lecturer/start_attendance_page.dart';
import '../../service/course_service.dart';

class CoursesPage extends StatefulWidget {

  final int lecturerId;
  final String token;

  const CoursesPage({
    super.key,
    required this.lecturerId,
    required this.token,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {

  List<Course> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {

      final result = await CourseService.getLecturerCourses(
        widget.lecturerId,
        widget.token,
      );

      setState(() {
        courses = result;
        isLoading = false;
      });

    } catch (e) {

      print("COURSE FETCH ERROR: $e");

      setState(() {
        isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Courses"),
        backgroundColor: const Color(0xFF034D08),
      ),

      backgroundColor: const Color(0xFFF4F6F8),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: courses.length,

        itemBuilder: (context, index) {

          final course = courses[index];

          return courseCard(
            context,
            code: course.code,
            title: course.name,
            level: course.level ?? "",
            semester: course.semester ?? "",
          );
        },
      ),
    );
  }

  Widget courseCard(
      BuildContext context, {
        required String code,
        required String title,
        required String level,
        required String semester,
      }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const Icon(
                Icons.menu_book,
                color: Color(0xFF034D08),
                size: 30,
              ),

              const SizedBox(width: 10),

              Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 4),

          Text(
            "$level • $semester",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              Expanded(
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF034D08),
                  ),


                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StartAttendancePage(
                          lecturerId: widget.lecturerId,
                          token: widget.token,
                        ),
                      ),
                    );

                  },

                  child: const Text(
                    "Start Attendance",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),

                  onPressed: () {},

                  child: const Text(
                    "View Records",
                    style: TextStyle(
                      color: Color(0xFF034D08),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}