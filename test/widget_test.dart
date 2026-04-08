import 'package:flutter/material.dart';
import 'package:student_attendance_app/screens/splash_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Attendance App',
      home: const SplashScreen(),
    );
  }
}