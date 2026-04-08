import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/api_client.dart';
import 'AddCourse.dart';
import 'add_course.dart';
import 'edit_course.dart';
import 'widgets/course_card.dart';

class CourseManagement extends StatefulWidget {
  const CourseManagement({super.key});

  @override
  State<CourseManagement> createState() => _CourseManagementState();
}

class _CourseManagementState extends State<CourseManagement> {

  List courses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {

    final response = await ApiClient.get("/admin/courses");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      setState(() {
        courses = data;
        loading = false;
      });

    } else {

      setState(() {
        loading = false;
      });

    }
  }

  Future<void> deleteCourse(int id) async {

    await ApiClient.delete("/admin/courses/$id");

    loadCourses();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Course Management"),
        backgroundColor: const Color(0xFF034D08),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF034D08),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCourse(),
            ),
          ).then((_) => loadCourses());
        },

        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search Course",
                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// COURSE LIST
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : courses.isEmpty
                  ? const Center(child: Text("No Courses Found"))
                  : ListView.builder(

                itemCount: courses.length,

                itemBuilder: (context, index) {

                  final course = courses[index];

                  return CourseCard(

                    code: course["code"],
                    title: course["name"],
                    lecturer: course["lecturer"]["fullName"],

                    onEdit: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCourse(
                            course: course,
                          ),
                        ),
                      ).then((_) => loadCourses());

                    },

                    onDelete: () {
                      deleteCourse(course["id"]);
                    },

                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }
}