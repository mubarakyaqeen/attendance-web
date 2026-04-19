import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/student_service.dart';
import 'attendance_success_screen.dart';

class JoinAttendanceScreen extends StatefulWidget {

  final int sessionId;
  final String token;

  final int courseId;
  final String courseCode;
  final String courseName;
  final String lecturerName;
  final int radius;

  final int durationMinutes;
  final String startedAt;


  const JoinAttendanceScreen({
    super.key,
    required this.sessionId,
    required this.token,
    required this.courseCode,
    required this.courseName,
    required this.lecturerName,
    required this.radius,
    required this.courseId,
    required this.durationMinutes,
    required this.startedAt,
  });

  @override
  State<JoinAttendanceScreen> createState() => _JoinAttendanceScreenState();
}

class _JoinAttendanceScreenState extends State<JoinAttendanceScreen> {

  static const Color primaryGreen = Color(0xFF034D08);
  static const Color primaryOrange = Color(0xFFF4A300);

  String locationStatus = "Location not checked";
  Color statusColor = Colors.grey;
  IconData statusIcon = Icons.location_on;

  double distance = 0;
  double allowedRadius = 0;

  bool insideRadius = false;

  final LocalAuthentication auth = LocalAuthentication();

  Timer? _timer;
  Duration remainingTime = Duration.zero;

  // ✅ SAFE setState
  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();

    allowedRadius = widget.radius.toDouble();

    checkBiometrics();     // async safe
    startCountdown();      // timer safe
  }

  /*
  =========================================
  LOCATION CHECK (currently simulated)
  =========================================
  */

  void checkLocation() {

    setState(() {

      /// simulate location result
      distance = 32;

      if (distance <= allowedRadius) {

        locationStatus = "Inside Radius";
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;

        insideRadius = true;

      } else {

        locationStatus = "Outside Radius";
        statusColor = Colors.red;
        statusIcon = Icons.cancel;

        insideRadius = false;
      }
    });
  }

  /*
  =========================================
  AUTHENTICATE STUDENT WITH FINGERPRINT
  BEFORE ALLOWING TO MARK ATTENDANCE
  =========================================
  */


  Future<bool> authenticateUser() async {
    try {
      final List<BiometricType> availableBiometrics =
      await auth.getAvailableBiometrics();

      print("Available biometrics: $availableBiometrics");

      if (availableBiometrics.isEmpty) {
        throw Exception("No biometric available (fingerprint/face not set)");
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Use fingerprint or face to mark attendance',
        options: const AuthenticationOptions(
          biometricOnly: true, // 🔥 allows BOTH fingerprint + face
          stickyAuth: true,
        ),
      );

      return authenticated;

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication error: $e")),
      );
      return false;
    }
  }


  /*
  =========================================
  MARK ATTENDANCE
  =========================================
  */


  Future<void> markAttendance() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");

      if (userId == null) {
        throw Exception("User not found");
      }

      print("➡️ Marking attendance...");
      print("studentId: $userId");
      print("sessionId: ${widget.sessionId}");

      final result = await StudentService.markAttendanceV2(
        studentId: userId,
        sessionId: widget.sessionId,
        token: widget.token,
        latitude: 0,
        longitude: 0,
      );

      print("✅ API RESPONSE: $result");

      if (!mounted) return;   // 🔥 IMPORTANT

      // ✅ SUCCESS NAVIGATION
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AttendanceSuccessScreen(),
        ),
      );

    } catch (e) {

      print("❌ ERROR: $e");

      if (!mounted) return;   // 🔥 IMPORTANT

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${e.toString()}")),
      );
    }
  }



  // Future<void> markAttendance() async {
  //   try {
  //
  //     // ⚠️ you must store userId in SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     final userId = prefs.getInt("userId");
  //
  //     if (userId == null) {
  //       throw Exception("User not found");
  //     }
  //
  //
  //     await StudentService.markAttendanceV2(
  //       studentId: userId,
  //       sessionId: widget.sessionId,
  //       token: widget.token,
  //       latitude: 0,
  //       longitude: 0,
  //     );
  //
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const AttendanceSuccessScreen(),
  //       ),
  //     );
  //
  //   } catch (e) {
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.toString())),
  //     );
  //
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Join Attendance"),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /*
            =================================
            COURSE INFO CARD
            =================================
            */

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
                      "${widget.courseCode} - ${widget.courseName}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Lecturer: ${widget.lecturerName}",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Allowed Radius: ${widget.radius} meters",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /*
            =================================
            LOCATION CHECK CARD
            =================================
            */

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

                    const Text(
                      "Location Verification",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 30,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          locationStatus,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Distance: ${distance.toStringAsFixed(0)} meters",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Allowed Radius: ${allowedRadius.toStringAsFixed(0)} meters",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 45,

                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                        ),

                        onPressed: checkLocation,

                        child: const Text(
                          "CHECK LOCATION",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            /*
            =================================
            COUNTDOWN TIMER (ADD HERE)
            =================================
            */

            Text(
              remainingTime.inSeconds <= 0
                  ? "⛔ Session expired"
                  : "⏱ Ends in: ${remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: remainingTime.inSeconds <= 0
                    ? Colors.red
                    : remainingTime.inSeconds < 181
                    ? Colors.orange
                    : Colors.green,
              ),
            ),


            /*
            =================================
            MARK ATTENDANCE BUTTON
            =================================
            */

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(

                onPressed: () async {

                  // 🔥 DEBUG (optional)
                  print("insideRadius: $insideRadius");
                  print("remainingTime: ${remainingTime.inSeconds}");

                  // ❌ LOCATION CHECK
                  if (!insideRadius) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("❌ You are outside the allowed location"),
                      ),
                    );
                    return;
                  }

                  // ❌ SESSION EXPIRED CHECK
                  if (remainingTime.inSeconds <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("⛔ Session has expired"),
                      ),
                    );
                    return;
                  }

                  // 🔥 BIOMETRIC AUTH
                  bool isAuthenticated = await authenticateUser();

                  if (!isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("❌ Authentication failed"),
                      ),
                    );
                    return;
                  }

                  // 🔥 MARK ATTENDANCE
                  await markAttendance();
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  "MARK ATTENDANCE",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryOrange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




 /*
=================================
FOR DEBUGGING OF BIOMETRICS
=================================
 */

  Future<void> checkBiometrics() async {
    try {
      final biometrics = await auth.getAvailableBiometrics();

      if (!mounted) return;   // 🔥 safety check

      print("Biometrics available: $biometrics");

    } catch (e) {
      print("Biometric error: $e");
    }
  }

  void startCountdown() {
    final start = DateTime.parse(widget.startedAt);
    final end = start.add(Duration(minutes: widget.durationMinutes));

    _timer?.cancel(); // 🔥 prevent duplicate timers

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {

      if (!mounted) {
        timer.cancel();   // 🔥 CRITICAL FIX
        return;
      }

      final now = DateTime.now();
      final diff = end.difference(now);

      setState(() {
        remainingTime = diff.isNegative ? Duration.zero : diff;
      });

      if (diff.isNegative) {
        timer.cancel();   // 🔥 stop timer when finished
      }
    });
  }

  /*
  =======================================
    Function to dispose after expiration
  =======================================
  */

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}