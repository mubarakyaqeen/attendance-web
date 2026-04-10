import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_attendance_app/screens/student/student_main.dart';

import 'login_screen.dart';
import 'admin/admin_dashboard.dart';
import 'lecturer/lecturer_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {

      if (kIsWeb) {
        // 🌐 WEB → Landing Page
        Navigator.pushReplacementNamed(context, '/landing');
      } else {
        // 📱 MOBILE → Login Page
        Navigator.pushReplacementNamed(context, '/app');
      }

    });
  }

  Future<void> startApp() async {

    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");
    final role = prefs.getString("role");

    Widget nextPage = const LoginScreen();

    if (token != null && role != null) {

      if (role == "ADMIN") {
        nextPage = const AdminDashboard();
      }

      else if (role == "LECTURER") {
        final lecturerId = prefs.getInt("lecturerId");

        if (lecturerId != null) {
          nextPage = LecturerHome(
            lecturerId: lecturerId,
            token: token,
          );
        }
      }

      else if (role == "STUDENT") {
        nextPage = const StudentMain();
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _PremiumSplashUI(),
    );
  }
}

class _PremiumSplashUI extends StatefulWidget {
  const _PremiumSplashUI();

  @override
  State<_PremiumSplashUI> createState() => _PremiumSplashUIState();
}

class _PremiumSplashUIState extends State<_PremiumSplashUI>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _fade = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _scale = Tween(begin: 0.85, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A3D2C), // dark green
            Color(0xFF0F6B4F), // medium green
            Color(0xFF14A06F), // light green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // 🔰 LOGO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/yabatech_logo.png", // 👈 PUT YOUR LOGO HERE
                    height: 120,
                  ),
                ),

                const SizedBox(height: 30),

                // 🏫 APP NAME
                const Text(
                  "Student Attendance System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Labore et Veritate",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 40),

                // ⏳ LOADING INDICATOR
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFFFFC107), // gold
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}