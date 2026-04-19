import 'dart:async';

import 'package:flutter/material.dart';
import 'package:student_attendance_app/screens/student/join_attendance_screen.dart';

import '../service/student_service.dart';
import '../models/student_dashboard_model.dart';

class StudentDashboard extends StatefulWidget {

  final int userId;
  final String token;


  const StudentDashboard({
    super.key,
    required this.userId,
    required this.token,
  });

  static const Color primaryGreen = Color(0xFF034D08);
  static const Color primaryOrange = Color(0xFFF4A300);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  Timer? _refreshTimer;

  StudentDashboardModel? dashboard;
  bool loading = true;
  String? error;


  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();

    fetchDashboard(); // first load

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) return;


      fetchDashboard();
    });
  }


  Future<void> fetchDashboard() async {
    try {


      final result = await StudentService.getDashboard(
        widget.userId,
        widget.token,
      );

      print("DASHBOARD SESSION ID: ${result.sessionId}");

      print("alreadyMarked: ${result.alreadyMarked}");

      print("sessionId: ${result.sessionId}");

      print("startedAt: ${result.startedAt}");

      safeSetState(() {
        dashboard = result;
        loading = false;
        error = null;
      });

    } catch (e) {

      safeSetState(() {
        error = e.toString();
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

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    final student = dashboard!;

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: StudentDashboard.primaryGreen,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDashboard,
          )
        ],
      ),

      body: RefreshIndicator(

        onRefresh: fetchDashboard,

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(blurRadius: 4, color: Colors.black12)
                  ],
                ),
                child: Row(
                  children: [

                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: StudentDashboard.primaryGreen,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),

                    const SizedBox(width: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Welcome \n ${student.fullName}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Matric: ${student.matricNumber}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    )

                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Active Attendance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (student.sessionId != null)

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "${student.courseCode} – ${student.courseTitle}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Lecturer: ${student.lecturerName}",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Radius: ${student.radius} meters",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: student.alreadyMarked

                          // ✅ SHOW MESSAGE
                              ? Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "✅ Attendance already marked",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )

                          // ✅ SHOW BUTTON
                              : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StudentDashboard.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            onPressed: () {

                              print("sessionId: ${student.sessionId}");
                              print("startedAt: ${student.startedAt}");

                              if (student.sessionId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("No active attendance session"),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JoinAttendanceScreen(
                                    courseId: student.courseId!,
                                    sessionId: student.sessionId!,
                                    token: widget.token,
                                    courseCode: student.courseCode!,
                                    courseName: student.courseTitle!,
                                    lecturerName: student.lecturerName!,
                                    radius: student.radius,

                                    // ✅ FRONTEND FALLBACK FIX
                                    durationMinutes: student.durationMinutes == 0
                                        ? 10
                                        : student.durationMinutes,

                                    startedAt: student.startedAt ?? DateTime.now().toIso8601String(),
                                  ),
                                ),
                              );
                            },

                            // onPressed: () {
                            //
                            //   // 🔥 SAFETY CHECK
                            //   if (student.sessionId == null || student.startedAt == null) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       const SnackBar(
                            //         content: Text("No active attendance session"),
                            //       ),
                            //     );
                            //     return;
                            //   }
                            //
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (_) => JoinAttendanceScreen(
                            //         courseId: student.courseId!,
                            //         sessionId: student.sessionId!,
                            //         token: widget.token,
                            //         courseCode: student.courseCode!,
                            //         courseName: student.courseTitle!,
                            //         lecturerName: student.lecturerName!,
                            //         radius: student.radius,
                            //         durationMinutes: student.durationMinutes,
                            //         startedAt: student.startedAt!, // ✅ now safe
                            //       ),
                            //     ),
                            //   );
                            // },

                            child: const Text(
                              "JOIN ATTENDANCE",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )

              else

                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No active attendance session",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              const Text(
                "My Courses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...student.courses.map((course) {

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(course),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );

              }).toList(),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();  // 🔥 STOP TIMER
    super.dispose();
  }
}