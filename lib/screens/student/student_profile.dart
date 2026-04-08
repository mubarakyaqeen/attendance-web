import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/student_profile_model.dart';
import '../../service/student_service.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../login_screen.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  static const Color primaryGreen = Color(0xFF034D08);
  static const Color primaryOrange = Color(0xFFF4A300);

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {

  StudentProfileModel? profile;
  bool loading = true;
  String? error;

  File? selectedImage;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /*
  =====================================
  LOAD PROFILE FROM BACKEND
  =====================================
  */
  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt("userId");
      final token = prefs.getString("token");

      if (userId == null || token == null) {
        throw Exception("User session not found");
      }

      final data = await StudentService.getProfile(userId, token);

      setState(() {
        profile = data;
        loading = false;
      });

    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  /*
  =====================================
  PICK IMAGE
  =====================================
  */
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });

      await uploadImage();
    }
  }

  /*
  =====================================
  UPLOAD IMAGE
  =====================================
  */
  Future<void> uploadImage() async {
    try {
      setState(() {
        uploading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      final token = prefs.getString("token");

      if (userId == null || token == null || selectedImage == null) {
        throw Exception("Missing data");
      }

      final imageUrl = await StudentService.uploadProfileImage(
        userId,
        selectedImage!,
        token,
      );

      await StudentService.updateProfileImage(
        userId,
        imageUrl,
        token,
      );

      await loadProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile image updated")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }

    setState(() {
      uploading = false;
    });
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

    final student = profile!;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: StudentProfile.primaryGreen,
        title: const Text("Student Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// PROFILE HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              color: Colors.white,

              child: Column(
                children: [

                  GestureDetector(
                    onTap: pickImage,

                    child: Column(
                      children: [

                        if (uploading)
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),

                        CircleAvatar(
                          radius: 80,

                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : (student.profileImageUrl != null &&
                              student.profileImageUrl!.isNotEmpty)
                              ? NetworkImage(student.profileImageUrl!)
                              : const AssetImage("assets/images/yabatech_logo.png")
                          as ImageProvider,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    student.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StudentProfile.primaryGreen,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Matric: ${student.matricNumber}",
                    style: const TextStyle(
                      color: StudentProfile.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// STUDENT INFO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [

                      ListTile(
                        leading: const Icon(Icons.school, color: StudentProfile.primaryGreen),
                        title: const Text("Department", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(student.department, style: const TextStyle(fontSize: 18)),
                      ),

                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.bar_chart, color: StudentProfile.primaryGreen),
                        title: const Text("Level", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(student.level, style: const TextStyle(fontSize: 18)),
                      ),

                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.email, color: StudentProfile.primaryGreen),
                        title: const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(student.email, style: const TextStyle(fontSize: 17)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ATTENDANCE STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Attendance Statistics",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: StudentProfile.primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [

                          Column(
                            children: [
                              Text("${student.present}",
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: StudentProfile.primaryGreen)),
                              const Text("Present"),
                            ],
                          ),

                          Column(
                            children: [
                              Text("${student.late}",
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: StudentProfile.primaryOrange)),
                              const Text("Late"),
                            ],
                          ),

                          Column(
                            children: [
                              Text("${student.absent}",
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                              const Text("Absent"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// LOGOUT (we fix next)
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudentProfile.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "LOGOUT",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: StudentProfile.primaryOrange,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear(); // 🔥 clears token, userId, role

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false, // 🔥 prevents back navigation
    );
  }
}



