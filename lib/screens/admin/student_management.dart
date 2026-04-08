import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/api_client.dart';
import 'widgets/student_card.dart';
import 'add_student.dart';

class StudentManagement extends StatefulWidget {
  const StudentManagement({super.key});

  @override
  State<StudentManagement> createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {

  List students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {

    try {

      final response = await ApiClient.get("/admin/students");

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          students = data is List ? data : data["students"] ?? [];
          loading = false;
        });

      } else {

        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load students")),
        );

      }

    } catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server connection error")),
      );

    }
  }

  Future<void> toggleBlock(int id) async {

    final response = await ApiClient.put(
      "/admin/students/$id/toggle-block",
      {},
    );

    if (response.statusCode == 200) {
      loadStudents();
    }
  }

  Future<void> deleteStudent(int id) async {

    final response = await ApiClient.delete(
      "/admin/students/$id",
    );

    if (response.statusCode == 200) {
      loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Student Management"),
        backgroundColor: const Color(0xFF034D08),
      ),

      /// ADD STUDENT BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF034D08),
        child: const Icon(Icons.person_add),
        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStudentPage(),
            ),
          );

          loadStudents();
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search Student",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// STUDENT LIST
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : students.isEmpty
                  ? const Center(child: Text("No Students Found"))
                  : ListView.builder(

                itemCount: students.length,

                itemBuilder: (context, index) {

                  final student = students[index];

                  return StudentCard(
                    name: student["fullName"] ?? "Unknown",
                    matric: student["matricNumber"] ?? "No Matric",
                    department: student["department"]?.toString() ?? "No Department",
                    blocked: student["blocked"] ?? false,

                    onBlock: () {
                      toggleBlock(student["id"]);
                    },

                    onDelete: () {
                      deleteStudent(student["id"]);
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