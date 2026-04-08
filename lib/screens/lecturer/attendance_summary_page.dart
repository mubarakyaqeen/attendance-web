import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/api_constants.dart';

class AttendanceSummaryPage extends StatefulWidget {

  final int lecturerId;
  final String token;

  const AttendanceSummaryPage({
    super.key,
    required this.lecturerId,
    required this.token,
  });

  @override
  State<AttendanceSummaryPage> createState() => _AttendanceSummaryPageState();
}

class _AttendanceSummaryPageState extends State<AttendanceSummaryPage> {

  List summaries = [];
  bool loading = true;

  Future<void> fetchSummary() async {

    try {

      final response = await http.get(
        Uri.parse(
            "${ApiConstants.baseUrl}/admin/lecturers/${widget.lecturerId}/attendance-summary"
        ),
        headers: {
          "Authorization": "Bearer ${widget.token}"
        },
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        setState(() {
          summaries = data;
          loading = false;
        });

      } else {

        setState(() {
          loading = false;
        });

      }

    } catch (e) {

      print("Attendance summary error: $e");

      setState(() {
        loading = false;
      });

    }

  }

  @override
  void initState() {
    super.initState();
    fetchSummary();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Attendance Summary"),
        backgroundColor: const Color(0xFF034D08),
      ),

      backgroundColor: const Color(0xFFF4F6F8),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : summaries.isEmpty
          ? const Center(child: Text("No attendance data available"))
          : ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: summaries.length,

        itemBuilder: (context, index) {

          final item = summaries[index];

          return summaryCard(
            course: item["courseCode"],
            title: item["courseName"],
            classes: item["totalSessions"].toString(),
            percentage: "${item["averageAttendance"]}%",
          );
        },
      ),
    );
  }

  Widget summaryCard({
    required String course,
    required String title,
    required String classes,
    required String percentage,
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

          Text(
            "$course - $title",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Total Classes",
                    style: TextStyle(fontSize: 16),
                  ),

                  Text(
                    classes,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Average Attendance",
                    style: TextStyle(fontSize: 16),
                  ),

                  Text(
                    percentage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF034D08),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}