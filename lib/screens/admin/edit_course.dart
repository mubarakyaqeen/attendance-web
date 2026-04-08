import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/api_client.dart';

class EditCourse extends StatefulWidget {

  final Map course;

  const EditCourse({super.key, required this.course});

  @override
  State<EditCourse> createState() => _EditCourseState();
}

class _EditCourseState extends State<EditCourse> {

  final codeController = TextEditingController();
  final nameController = TextEditingController();

  List departments = [];
  List lecturers = [];

  int? selectedDepartment;
  int? selectedLecturer;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    /// Fill existing values
    codeController.text = widget.course["code"];
    nameController.text = widget.course["name"];

    selectedDepartment = widget.course["department"]["id"];
    selectedLecturer = widget.course["lecturer"]["id"];

    loadDepartments();
    loadLecturers();
  }

  Future<void> loadDepartments() async {

    final response = await ApiClient.get("/admin/departments");

    if (response.statusCode == 200) {

      setState(() {
        departments = jsonDecode(response.body);
      });

    }
  }

  Future<void> loadLecturers() async {

    final response = await ApiClient.get("/admin/lecturers");

    if (response.statusCode == 200) {

      setState(() {
        lecturers = jsonDecode(response.body);
      });

    }
  }

  Future<void> updateCourse() async {

    setState(() {
      loading = true;
    });

    final response = await ApiClient.put(
      "/admin/courses/${widget.course["id"]}",
      {
        "code": codeController.text,
        "name": nameController.text,
        "departmentId": selectedDepartment,
        "lecturerId": selectedLecturer
      },
    );

    setState(() {
      loading = false;
    });

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course updated successfully")),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update course")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Course"),
        backgroundColor: const Color(0xFF034D08),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// COURSE CODE
            TextField(
              controller: codeController,

              decoration: const InputDecoration(
                labelText: "Course Code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// COURSE NAME
            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                labelText: "Course Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// DEPARTMENT
            DropdownButtonFormField<int>(

              value: selectedDepartment,

              items: departments.map<DropdownMenuItem<int>>((dept) {

                return DropdownMenuItem<int>(
                  value: dept["id"],
                  child: Text(dept["name"]),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedDepartment = value;
                });

              },

              decoration: const InputDecoration(
                labelText: "Department",
                border: OutlineInputBorder(),
              ),

            ),

            const SizedBox(height: 20),

            /// LECTURER
            DropdownButtonFormField<int>(

              value: selectedLecturer,

              items: lecturers.map<DropdownMenuItem<int>>((lecturer) {

                return DropdownMenuItem<int>(
                  value: lecturer["id"],
                  child: Text(lecturer["fullName"]),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedLecturer = value;
                });

              },

              decoration: const InputDecoration(
                labelText: "Lecturer",
                border: OutlineInputBorder(),
              ),

            ),

            const SizedBox(height: 30),

            /// UPDATE BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: loading ? null : updateCourse,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF034D08),
                ),

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Course"),

              ),
            )

          ],
        ),
      ),
    );
  }
}