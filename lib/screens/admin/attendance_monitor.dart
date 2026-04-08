import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/api_client.dart';
import 'widgets/attendance_card.dart';

class AttendanceMonitor extends StatefulWidget {
  const AttendanceMonitor({super.key});

  @override
  State<AttendanceMonitor> createState() => _AttendanceMonitorState();
}

class _AttendanceMonitorState extends State<AttendanceMonitor> {

  List sessions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {

    final response = await ApiClient.get("/admin/attendance/sessions");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      setState(() {
        sessions = data;
        loading = false;
      });

    } else {

      setState(() {
        loading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Attendance Monitoring"),
        backgroundColor: const Color(0xFF034D08),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              decoration: InputDecoration(
                hintText: "Search Course or Lecturer",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : sessions.isEmpty
                  ? const Center(child: Text("No Sessions Found"))
                  : ListView.builder(

                itemCount: sessions.length,

                itemBuilder: (context, index) {

                  final session = sessions[index];

                  return AttendanceCard(
                    course:
                    "${session["courseCode"]} : \n ${session["courseName"]}",

                    lecturer: session["lecturerName"],

                    date: session["date"],

                    present: session["present"],

                    absent: session["absent"],

                    location: "Classroom",

                    active: session["active"],
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