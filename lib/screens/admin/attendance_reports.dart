import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:student_attendance_app/screens/admin/widgets/attendance_pie_chart.dart';

import '../../utils/api_client.dart';
import 'widgets/report_card.dart';
import 'widgets/attendance_chart.dart';

class AttendanceReports extends StatefulWidget {
  const AttendanceReports({super.key});

  @override
  State<AttendanceReports> createState() => _AttendanceReportsState();
}

class _AttendanceReportsState extends State<AttendanceReports> {

  Map summary = {};
  List trend = [];
  bool loading = true;

  String selectedFilter = "ALL";

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {

    final summaryRes = await ApiClient.get(
        "/admin/reports/summary?filter=$selectedFilter");

    final trendRes = await ApiClient.get(
        "/admin/reports/trend?filter=$selectedFilter");

    print("SUMMARY RESPONSE: ${summaryRes.body}");
    print("TREND RESPONSE: ${trendRes.body}");

    if (summaryRes.statusCode == 200 && trendRes.statusCode == 200) {

      setState(() {
        summary = jsonDecode(summaryRes.body);
        trend = jsonDecode(trendRes.body);
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

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final double percentage =
    (summary["overallAttendance"] ?? 0).toDouble();

    final int courses = summary["coursesMonitored"] ?? 0;
    final int students = summary["totalStudents"] ?? 0;
    final int sessions = summary["attendanceSessions"] ?? 0;


    final reports = [

      {
        "title": "Attendance %",
        "value": "${percentage.toStringAsFixed(1)}%",
        "icon": Icons.pie_chart
      },

      {
        "title": "Courses",
        "value": courses.toString(),
        "icon": Icons.menu_book
      },

      {
        "title": "Students",
        "value": students.toString(),
        "icon": Icons.people
      },

      {
        "title": "Sessions",
        "value": sessions.toString(),
        "icon": Icons.location_on
      },

    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Attendance Reports"),
        backgroundColor: const Color(0xFF034D08),
      ),

      backgroundColor: const Color(0xFFF5F7FA),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// SUMMARY
            const Text(
              "Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: reports.length,
              itemBuilder: (context, index) {

                final report = reports[index];

                return ReportCard(
                  title: report["title"] as String,
                  value: report["value"] as String,
                  icon: report["icon"] as IconData,
                );
              },
            ),

            const SizedBox(height: 25),

            /// FILTER SECTION
            const Text("Filter", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterBtn("ALL"),
                  _filterBtn("TODAY"),
                  _filterBtn("WEEK"),
                  _filterBtn("MONTH"),
                ],
              ),
            ),
            

            const SizedBox(height: 25),

            /// PIE CHART
            const Text(
              "Attendance Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            AttendancePieChart(
              present: sessions,
              late: courses,
              absent: students,
            ),

            const SizedBox(height: 30),

            /// BREAKDOWN
            const Text(
              "Attendance Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(15),
            //   ),
            //   child: Column(
            //     children: [
            //       _row("Total Records", total),
            //       _row("Present", present),
            //       _row("Late", late),
            //       _row("Absent", absent),
            //     ],
            //   ),
            // ),

            const SizedBox(height: 30),

            /// TREND
            const Text(
              "Attendance Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            AttendanceChart(trendData: trend),

            const SizedBox(height: 30),

            /// EXPORT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: exportPDF,
                icon: const Icon(Icons.download),
                label: const Text("Export Attendance Report"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF034D08),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// FILTER BUTTON
  Widget _filterBtn(String label) {

    final isSelected = selectedFilter == label;

    return ElevatedButton(

      onPressed: () async {

        setState(() {
          selectedFilter = label;
          loading = true;
        });

        await loadReports(); // 🔥 reload from backend
      },

      style: ElevatedButton.styleFrom(
        backgroundColor:
        isSelected ? const Color(0xFF034D08) : Colors.grey[300],
      ),

      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  /// EXPORT PDF
  Future<void> exportPDF() async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                "Attendance Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Total Records: ${summary["totalRecords"] ?? 0}"),
              pw.Text("Present: ${summary["present"] ?? 0}"),
              pw.Text("Late: ${summary["late"] ?? 0}"),
              pw.Text("Absent: ${summary["absent"] ?? 0}"),

              pw.SizedBox(height: 20),

              pw.Text("Attendance Trend",
                  style: pw.TextStyle(fontSize: 18)),

              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [

                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Date"),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Count"),
                      ),
                    ],
                  ),

                  ...trend.map((item) {

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item["date"].toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              (item["count"] ?? 0).toString()),
                        ),
                      ],
                    );

                  }).toList()

                ],
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Generated on: ${DateTime.now()}",
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}