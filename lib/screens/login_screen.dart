import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_attendance_app/screens/student/student_main.dart';
import 'package:student_attendance_app/screens/student_dashboard.dart';

import '../service/auth_service.dart';
import 'admin/admin_dashboard.dart';
import 'lecturer/lecturer_home.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  static const Color primaryGreen = Color(0xFF034D08);
  static const Color primaryOrange = Color(0xFFF4A300);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /*
  =====================================
  INPUT FIELD DECORATION
  =====================================
  */

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(
        icon,
        color: primaryGreen,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 2,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryOrange,
          width: 2.5,
        ),
      ),
    );
  }

  /*
  =====================================
  LOGIN FUNCTION
  =====================================
  */

  Future<void> loginUser() async {

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter email and password")),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final authService = AuthService();

      /*
      Call backend login API
      */
      final user = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      /*
      If login fails
      */
      if (user == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid login")),
        );

        return;
      }

      /*
      Save login session locally
      */
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", user.token);
      await prefs.setString("role", user.role);
      await prefs.setInt("userId", user.id);

      if (user.lecturerId != null) {
        await prefs.setInt("lecturerId", user.lecturerId!);
      }

      /*
      =====================================
      ROLE BASED NAVIGATION
      =====================================
      */

      switch (user.role) {

      /*
        =============================
        ADMIN LOGIN
        =============================
        */

        case "ADMIN":

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminDashboard(),
            ),
          );
          break;

      /*
        =============================
        LECTURER LOGIN
        =============================
        */

        case "LECTURER":

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LecturerHome(
                lecturerId: user.lecturerId!,
                token: user.token,
              ),
            ),
          );
          break;

      /*
        =============================
        STUDENT LOGIN
        =============================
        */

        case "STUDENT":

        /*
          IMPORTANT:
          Send student to StudentDashboard
          (this page fetches real attendance
          sessions from the database)
          */

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const StudentMain(),
            ),
          );
          break;

      /*
        UNKNOWN ROLE
        */

        default:

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unknown role")),
          );
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    }
  }

  /*
  =====================================
  UI BUILD
  =====================================
  */

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [

              const SizedBox(height: 40),

              Image.asset(
                "assets/images/yabatech_logo.png",
                width: 100,
              ),

              const SizedBox(height: 20),

              const Text(
                "Student Attendance System",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(height: 40),

              /*
              EMAIL FIELD
              */

              TextField(
                controller: emailController,
                decoration: inputDecoration(
                  "Email / Matric",
                  Icons.person,
                ),
              ),

              const SizedBox(height: 20),

              /*
              PASSWORD FIELD
              */

              TextField(
                controller: passwordController,
                obscureText: hidePassword,

                decoration: inputDecoration(
                  "Password",
                  Icons.lock,
                ).copyWith(

                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: primaryGreen,
                    ),

                    onPressed: () {

                      setState(() {
                        hidePassword = !hidePassword;
                      });

                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /*
              LOGIN BUTTON
              */

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  onPressed: isLoading ? null : loginUser,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /*
              REGISTER BUTTON
              */

              TextButton(

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );

                },

                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    color: primaryOrange,
                    fontWeight: FontWeight.bold,
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