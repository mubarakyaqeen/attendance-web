import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../service/auth_service.dart';
import '../../utils/api_constants.dart';
import '../login_screen.dart';
import 'attendance_records_page.dart';
import 'attendance_summary_page.dart';
import 'courses_page.dart';
import 'create_courses_page.dart';

class DashboardPage extends StatefulWidget {

  final int lecturerId;
  final String token;

  const DashboardPage({
    super.key,
    required this.lecturerId,
    required this.token,
  });



  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchActiveSession(); // ✅ correct place
  }

  Timer? _refreshTimer;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  int courses = 0;
  int students = 0;
  String lecturerName = "";
  bool isLoading = true;

  Map<String, dynamic>? activeSession;

  /*
   * Fetch dashboard statistics
   */
  Future<void> fetchDashboard() async {

    try {

      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/lecturer/dashboard/${widget.lecturerId}"),
        headers: {
          "Authorization": "Bearer ${widget.token}"
        },
      );

      if (response.statusCode == 200) {

        final data = json.decode(response.body);

        setState(() {
          courses = data["courses"] ?? 0;
          students = data["students"] ?? 0;
          lecturerName = data["name"] ?? "";
          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });

      }

    } catch (e) {

      print("Dashboard error: $e");

      setState(() {
        isLoading = false;
      });

    }
  }

  /*
   * Fetch active attendance session
   */
  Future<void> fetchActiveSession() async {

    try {

      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/lecturer/${widget.lecturerId}/active-session"),
        headers: {
          "Authorization": "Bearer ${widget.token}"
        },
      );

      if (response.statusCode == 200) {

        if (response.body.isEmpty || response.body == "null") {

          setState(() {
            activeSession = null;
          });

          return;
        }

        final data = jsonDecode(response.body);

        setState(() {
          activeSession = data;
        });

      }

    } catch (e) {
      print("Active session error: $e");
    }
  }

  /*
   * Stop attendance session
   */
  Future<void> stopSession() async {

    if (activeSession == null) return;

    final sessionId = activeSession!["sessionId"];

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/lecturer/end-session/$sessionId"),
      headers: {
        "Authorization": "Bearer ${widget.token}"
      },
    );

    if (response.statusCode == 200) {

      setState(() {
        activeSession = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance session closed"),
        ),
      );

    }

  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    fetchDashboard();
    fetchActiveSession();

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) return;

      fetchDashboard();
      fetchActiveSession();
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,

          child: RefreshIndicator(
            onRefresh: () async {
              await fetchDashboard();
              await fetchActiveSession();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // 🔥 IMPORTANT

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Image.asset(
                        "assets/images/yabatech_logo.png",
                        width: 45,
                      ),

                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFFF9800),
                        child: Icon(Icons.person, color: Colors.white),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// WELCOME
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  Text(
                    lecturerName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF034D08),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// STATISTICS
                  Row(
                    children: [

                      Expanded(
                        child: statCard(
                          icon: Icons.menu_book,
                          value: courses.toString(),
                          label: "Courses",
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: statCard(
                          icon: Icons.people,
                          value: students.toString(),
                          label: "Students",
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 25),

                  /// ACTIVE SESSION
                  if(activeSession != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Row(
                        children: [

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  "Active Attendance Session",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  activeSession!["courseCode"] ?? "",
                                  style: const TextStyle(fontSize: 14),
                                ),

                              ],
                            ),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: stopSession,
                            child: const Text("CLOSE"),
                          ),

                        ],
                      ),
                    ),

                  const SizedBox(height: 25),

                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,

                    children: [

                      dashboardCard(
                        icon: Icons.add_box,
                        title: "Create Course",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateCoursePage(),
                            ),
                          );
                        },
                      ),

                      dashboardCard(
                        icon: Icons.menu_book,
                        title: "View Courses",
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoursesPage(
                                lecturerId: widget.lecturerId,
                                token: widget.token,
                              ),
                            ),
                          );

                        },
                      ),

                      dashboardCard(
                        icon: Icons.analytics,
                        title: "Attendance Summary",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceSummaryPage(
                                lecturerId: widget.lecturerId,
                                token: widget.token,
                              ),
                            ),
                          );
                        },
                      ),

                      dashboardCard(
                        icon: Icons.fact_check,
                        title: "Attendance Records",
                        onTap: () {

                          if(activeSession == null){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No active session"),
                              ),
                            );
                            return;
                          }

                          final sessionId = activeSession!["sessionId"];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttendanceRecordsPage(
                                sessionId: sessionId,
                                token: widget.token,
                              ),
                            ),
                          );

                        },
                      ),

                      dashboardCard(
                        icon: Icons.logout,
                        title: "Logout",
                        iconColor: Colors.orange,
                        onTap: () async {

                          await AuthService().logout();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                                (route) => false,
                          );

                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {

    return Container(
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
        children: [

          Icon(icon, size: 30, color: const Color(0xFF034D08)),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF034D08),
  }) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
            )
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(icon, size: 40, color: iconColor),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // 🔥 prevent memory leak
    _controller.dispose();
    super.dispose();
  }

}