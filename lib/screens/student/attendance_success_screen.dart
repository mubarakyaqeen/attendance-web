import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/student_service.dart';

class AttendanceSuccessScreen extends StatefulWidget {
  const AttendanceSuccessScreen({super.key});

  @override
  State<AttendanceSuccessScreen> createState() => _AttendanceSuccessScreenState();
}

class _AttendanceSuccessScreenState extends State<AttendanceSuccessScreen> {

  static const Color primaryGreen = Color(0xFF034D08);
  static const Color primaryOrange = Color(0xFFF4A300);

  Map<String, dynamic>? attendance;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt("userId");
      final token = prefs.getString("token");

      if (userId == null || token == null) {
        throw Exception("User session not found");
      }

      final data = await StudentService.getLatestAttendance(userId, token);

      if (!mounted) return;

      setState(() {
        attendance = data;
        loading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  String formatTime(String? dateTime) {
    if (dateTime == null) return "N/A";

    final dt = DateTime.parse(dateTime);

    int hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text("Attendance Result"),
        centerTitle: true,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: loading
              ? const CircularProgressIndicator()
              : error != null
              ? Text(error!)
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// SUCCESS ICON
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 120,
              ),

              const SizedBox(height: 20),

              /// TITLE
              const Text(
                "Attendance Recorded",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(height: 30),

              /// COURSE INFO CARD
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      /// COURSE
                      ListTile(
                        leading: const Icon(Icons.book, color: primaryGreen),
                        title: const Text(
                          "Course",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "${attendance?["session"]?["course"]?["code"] ?? "N/A"} - ${attendance?["session"]?["course"]?["name"] ?? ""}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const Divider(),

                      /// TIME
                      ListTile(
                        leading: const Icon(Icons.access_time, color: primaryGreen),
                        title: const Text(
                          "Time Recorded",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          formatTime(attendance?["markedAt"]),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const Divider(),

                      /// STATUS
                      ListTile(
                        leading: const Icon(Icons.verified, color: primaryGreen),
                        title: const Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          attendance?["status"] ?? "Present",
                          style: const TextStyle(
                            color: primaryOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// BACK BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },

                  child: const Text(
                    "BACK TO DASHBOARD",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryOrange,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}