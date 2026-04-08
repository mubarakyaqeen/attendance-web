import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/api_client.dart';

class AddCourse extends StatefulWidget {
  const AddCourse({super.key});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {

  final codeController = TextEditingController();
  final nameController = TextEditingController();

  List departments = [];
  List lecturers = [];

  int? selectedDepartment;
  int? selectedLecturer;

  @override
  void initState() {
    super.initState();
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

  Future<void> createCourse() async {

    await ApiClient.post(
      "/admin/courses",
      {
        "code": codeController.text,
        "name": nameController.text,
        "departmentId": selectedDepartment,
        "lecturerId": selectedLecturer
      },
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Course"),
        backgroundColor: const Color(0xFF034D08),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: codeController,

              decoration: const InputDecoration(
                labelText: "Course Code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                labelText: "Course Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<int>(

              hint: const Text("Select Department"),

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

            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<int>(

              hint: const Text("Select Lecturer"),

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

            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: createCourse,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF034D08),
                ),

                child: const Text("Create Course"),

              ),
            )

          ],
        ),
      ),
    );
  }
}