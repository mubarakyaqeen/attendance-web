import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:student_attendance_app/screens/admin/student_management.dart';
import 'package:student_attendance_app/screens/admin/widgets/admin_attendance_pie_chart.dart';
import 'package:student_attendance_app/screens/admin/widgets/attendance_line_chart.dart';
import 'package:student_attendance_app/screens/admin/widgets/stacked_attendance_chart.dart';
import '../../utils/api_client.dart';

import '../login_screen.dart';
import 'attendance_monitor.dart';
import 'attendance_reports.dart';
import 'course_management.dart';
import 'create_department_page.dart';
import 'lecturer_management.dart';
import 'widgets/stat_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/section_title.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  Timer? _refreshTimer;

  int students = 0;
  int lecturers = 0;
  int courses = 0;
  int sessions = 0;

  List trend = [];
  List allSessions = [];
  List liveSessions = [];

  bool loading = true;
  bool isToggling = false;

  /// ✅ FIXED PIE DATA (GLOBAL STATE)
  int totalPresent = 0;
  int totalLate = 0;
  int totalAbsent = 0;

  @override
  void initState() {
    super.initState();

    loadDashboardData(); // first load

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) return;
      loadDashboardData();
    });
  }

  Future<void> loadDashboardData() async {

    final statsResponse = await ApiClient.get("/admin/dashboard");
    final trendResponse = await ApiClient.get("/admin/reports/trend");
    final sessionsResponse = await ApiClient.get("/admin/attendance/sessions");
    final liveResponse = await ApiClient.get("/admin/attendance/live-sessions");

    if (statsResponse.statusCode == 200) {
      final data = jsonDecode(statsResponse.body);

      students = data["students"] ?? 0;
      lecturers = data["lecturers"] ?? 0;
      courses = data["courses"] ?? 0;
      sessions = data["sessions"] ?? 0;
    }

    if (trendResponse.statusCode == 200) {
      trend = jsonDecode(trendResponse.body);
    }

    if (sessionsResponse.statusCode == 200) {
      allSessions = jsonDecode(sessionsResponse.body);
    }

    if (liveResponse.statusCode == 200) {
      liveSessions = jsonDecode(liveResponse.body);
    }

    /// ✅ CALCULATE PIE DATA (FIXED)
    totalPresent = 0;
    totalLate = 0;
    totalAbsent = 0;

    for (var session in allSessions) {
      totalPresent += (session["present"] ?? 0) as int;
      totalLate += (session["late"] ?? 0) as int;
      totalAbsent += (session["absent"] ?? 0) as int;
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFF034D08),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadDashboardData,
          )
        ],
      ),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: loadDashboardData,
          child: SingleChildScrollView(

        child: Column(
          children: [

            const SectionTitle(title: "Overview"),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                StatCard(icon: Icons.school, title: "Total Students", value: students.toString()),
                StatCard(icon: Icons.person, title: "Total Lecturers", value: lecturers.toString()),
                StatCard(icon: Icons.menu_book, title: "Total Courses", value: courses.toString()),
                StatCard(icon: Icons.location_on, title: "Active Sessions", value: sessions.toString()),
              ],
            ),

            const SizedBox(height: 25),

            /// 🔥 STACKED BAR CHART
            const SectionTitle(title: "Session Attendance"),

            allSessions.isEmpty
                ? const Text("No Data")
                : StackedAttendanceChart(sessions: allSessions),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.square, color: Colors.green, size: 12),
                SizedBox(width: 5),
                Text("Present"),
                SizedBox(width: 15),
                Icon(Icons.square, color: Colors.orange, size: 12),
                SizedBox(width: 5),
                Text("Late"),
                SizedBox(width: 15),
                Icon(Icons.square, color: Colors.red, size: 12),
                SizedBox(width: 5),
                Text("Absent"),
              ],
            ),

            const SizedBox(height: 25),

            /// 🔥 PIE CHART (FIXED)
            const SectionTitle(title: "Attendance Distribution"),

            AdminAttendancePieChart(
              present: totalPresent,
              late: totalLate,
              absent: totalAbsent,
            ),

            const SizedBox(height: 25),

            /// 🔥 LINE CHART
            const SectionTitle(title: "Attendance Trend"),

            trend.isEmpty
                ? const Text("No Trend Data")
                : AttendanceLineChart(trend: trend),

            const SizedBox(height: 25),

            /// QUICK ACTIONS
            const SectionTitle(title: "Quick Actions"),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [

                QuickActionCard(
                  icon: Icons.account_tree,
                  title: "Create Department",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateDepartmentPage())),
                ),

                QuickActionCard(
                  icon: Icons.person_add,
                  title: "Add Lecturer",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LecturerManagement())),
                ),

                QuickActionCard(
                  icon: Icons.book,
                  title: "Add Course",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseManagement())),
                ),

                QuickActionCard(
                  icon: Icons.visibility,
                  title: "Attendance Monitor",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceMonitor())),
                ),

                QuickActionCard(
                  icon: Icons.analytics,
                  title: "Attendance Reports",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceReports())),
                ),

                QuickActionCard(
                  icon: Icons.manage_accounts,
                  title: "Manage Students",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentManagement())),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// LIVE SESSIONS
            const SectionTitle(title: "Live Attendance Sessions"),

            liveSessions.isEmpty
                ? const Text("No Active Sessions")
                : Column(
              children: liveSessions.map((session){

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Row(
                    children: [

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              session["course"] ?? "Unknown Course",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 5),

                            Text("Lecturer: ${session["lecturer"] ?? "N/A"}"),

                            const SizedBox(height: 5),

                            Text("Present: ${session["present"] ?? 0}"),
                            Text("Late: ${session["late"] ?? 0}"),
                            Text("Absent: ${session["absent"] ?? 0}"),

                          ],
                        ),
                      ),

                      const Icon(Icons.location_on, color: Color(0xFF034D08)),
                    ],
                  ),
                );

              }).toList(),
            ),

            const SizedBox(height: 25),

            /// SYSTEM CONTROL
            const SectionTitle(title: "System Control"),

            ElevatedButton.icon(
              onPressed: isToggling ? null : () async {

                setState(() => isToggling = true);

                try {

                  final response = await ApiClient.put(
                    "/admin/system/toggle-registration",
                    {},
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Registration status updated")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed: ${response.body}")),
                    );
                  }

                } catch (e) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );

                } finally {
                  setState(() => isToggling = false);
                }
              },

              icon: isToggling
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : const Icon(Icons.block, color: Colors.white),

              label: Text(
                isToggling ? "Processing..." : "Block / Unblock Registration",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 55),
              ),
            ),

            const SizedBox(height: 40),

            /// LOGOUT
            ElevatedButton.icon(
              onPressed: () async {

                await ApiClient.clearToken();

                if(!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },

              icon: const Icon(Icons.logout, color: Colors.white),

              label: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    );
        }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // 🔥 prevent memory leak
    super.dispose();
  }
}