import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/api_client.dart';
import 'add_lecturer.dart';
import 'edit_lecturer.dart';
import 'widgets/lecturer_card.dart';

class LecturerManagement extends StatefulWidget {
  const LecturerManagement({super.key});

  @override
  State<LecturerManagement> createState() => _LecturerManagementState();
}

class _LecturerManagementState extends State<LecturerManagement> {

  List lecturers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadLecturers();
  }

  Future<void> loadLecturers() async {

    final response = await ApiClient.get("/admin/lecturers");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      setState(() {
        lecturers = data;
        loading = false;
      });

    } else {

      setState(() {
        loading = false;
      });

    }
  }

  Future<void> deleteLecturer(int id) async {

    await ApiClient.delete("/admin/lecturers/$id");

    loadLecturers();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Lecturer Management"),
        backgroundColor: const Color(0xFF034D08),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF034D08),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddLecturer(),
            ),
          ).then((_) => loadLecturers());
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
                hintText: "Search Lecturer",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LECTURER LIST
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : lecturers.isEmpty
                  ? const Center(child: Text("No Lecturers Found"))
                  : ListView.builder(

                itemCount: lecturers.length,

                itemBuilder: (context, index) {

                  final lecturer = lecturers[index];

                  return LecturerCard(
                    name: lecturer["fullName"],
                    department: lecturer["department"],

                    onEdit: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditLecturer(
                            lecturer: lecturer,
                          ),
                        ),
                      ).then((_) => loadLecturers());

                    },

                    onDelete: () {
                      deleteLecturer(lecturer["id"]);
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