import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';

import '../../utils/api_constants.dart';

class StartAttendancePage extends StatefulWidget {

  final int lecturerId;
  final String token;

  const StartAttendancePage({
    super.key,
    required this.lecturerId,
    required this.token
  });

  @override
  State<StartAttendancePage> createState() => _StartAttendancePageState();
}

class _StartAttendancePageState extends State<StartAttendancePage> {

  final String baseUrl = ApiConstants.baseUrl;

  final LocalAuthentication auth = LocalAuthentication();

  List courses = [];

  int? selectedCourseId;

  int radius = 50;

  int duration = 10;

  double? latitude;
  double? longitude;

  Map<String, dynamic>? activeSession;

  /*
   * FETCH COURSES
   */
  Future<void> fetchCourses() async {

    final url =
    Uri.parse("$baseUrl/lecturer/${widget.lecturerId}/courses");

    try {

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}"
        },
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        if (!mounted) return;   // 🔥 FIX (prevents crash)

        setState(() {
          courses = data;

          if (courses.isNotEmpty) {
            selectedCourseId = courses[0]["id"];
          }
        });

      }

    } catch (e) {

      if (!mounted) return;   // 🔥 FIX (also for errors)

      // Optional: you can log or show error
      print("Error fetching courses: $e");
    }
  }

  /*
   * CHECK ACTIVE SESSION
   */
  Future<void> checkActiveSession() async {

    final url = Uri.parse(
        "$baseUrl/lecturer/${widget.lecturerId}/active-session"
    );

    try {

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}"
        },
      );

      if (response.statusCode == 200) {

        if (response.body.isEmpty) {
          print("Empty response from server");

          if (!mounted) return;

          setState(() {
            activeSession = null;
          });

          return;
        }

        final data = jsonDecode(response.body);

        if (!mounted) return;   // 🔥 prevents crash

        setState(() {
          activeSession = data;
        });

      } else {

        if (!mounted) return;

        setState(() {
          activeSession = null;
        });

      }

    } catch (e) {
      print("Error fetching active session: $e");

      if (!mounted) return;

      setState(() {
        activeSession = null;
      });
    }
  }

  /*
   * GET GPS LOCATION
   */
  Future<void> getLocation() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable GPS")),
      );

      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latitude = position.latitude;
    longitude = position.longitude;

  }

  /*
   * BIOMETRIC AUTH
   */
  Future<bool> authenticate() async {

    try {

      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool supported = await auth.isDeviceSupported();

      if(!canCheckBiometrics || !supported){
        return false;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: "Verify your identity to start attendance",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return authenticated;

    } catch(e){

      print("BIOMETRIC ERROR: $e");
      return false;
    }

  }

  /*
   * START ATTENDANCE
   */
  Future<void> startAttendance() async {

    if(activeSession != null){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A session is already active")),
      );

      return;
    }

    bool verified = await authenticate();

    if(!verified){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fingerprint verification failed")),
      );

      return;
    }

    await getLocation();

    final url =
    Uri.parse("$baseUrl/lecturer/attendance/start-session");

    final body = {

      "courseId": selectedCourseId,
      "lecturerId": widget.lecturerId,
      "durationMinutes": duration,
      "latitude": latitude,
      "longitude": longitude,
      "radiusMeters": radius
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}"
      },
      body: jsonEncode(body),
    );

    // 🔥 REPLACE ONLY THIS PART INSIDE startAttendance()

    if(response.statusCode == 200){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance session started")),
      );

      // ✅ NEW: go back to dashboard (no logic broken)
      Navigator.pop(context);
      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to start session")),
      );

    }

  }

  /*
   * STOP SESSION
   */
  Future<void> stopSession() async {

    final sessionId = activeSession!["sessionId"];

    final url = Uri.parse(
        "$baseUrl/lecturer/attendance/stop-session/$sessionId"
    );

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${widget.token}"
      },
    );

    if(response.statusCode == 200){

      setState(() {
        activeSession = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance session stopped")),
      );

    }

  }

  @override
  void initState() {
    super.initState();
    fetchCourses();
    checkActiveSession();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Start Attendance"),
        backgroundColor: const Color(0xFF034D08),
      ),

      backgroundColor: const Color(0xFFF4F6F8),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /*
             * ACTIVE SESSION CARD
             */

            if(activeSession != null)
              Card(
                color: Colors.green.shade100,
                child: ListTile(
                  title: Text(
                    "Active Session: ${activeSession!['courseCode']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Attendance currently running"),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: stopSession,
                    child: const Text("STOP"),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            /*
             * COURSE
             */

            const Text(
              "Select Course",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(

              isExpanded: true,

              value: selectedCourseId,

              items: courses.map<DropdownMenuItem<int>>((course){

                return DropdownMenuItem(
                  value: course["id"],
                  child: Text("${course["code"]} - ${course["name"]}"),
                );

              }).toList(),

              onChanged: (value){

                setState(() {
                  selectedCourseId = value;
                });

              },

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),

            const SizedBox(height: 20),

            /*
             * RADIUS
             */

            const Text(
              "Attendance Radius",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(

              value: radius,

              items: const [

                DropdownMenuItem(
                    value: 20,
                    child: Text("20 meters")
                ),

                DropdownMenuItem(
                    value: 50,
                    child: Text("50 meters")
                ),

                DropdownMenuItem(
                    value: 100,
                    child: Text("100 meters")
                ),

              ],

              onChanged: (value){

                setState(() {
                  radius = value!;
                });

              },

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),

            const SizedBox(height: 20),

            /*
             * DURATION
             */

            const Text(
              "Session Duration",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(

              value: duration,

              items: const [

                DropdownMenuItem(
                    value: 5,
                    child: Text("5 minutes")
                ),

                DropdownMenuItem(
                    value: 10,
                    child: Text("10 minutes")
                ),

                DropdownMenuItem(
                    value: 15,
                    child: Text("15 minutes")
                ),

              ],

              onChanged: (value){

                setState(() {
                  duration = value!;
                });

              },

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),

            const Spacer(),

            /*
             * START BUTTON
             */

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF034D08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),

                onPressed: startAttendance,

                child: const Text(
                  "Start Attendance Session",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }



  @override
  void dispose() {
    super.dispose();
  }
}