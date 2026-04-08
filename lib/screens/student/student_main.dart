import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../student_dashboard.dart';
import 'my_courses.dart';
import 'attendance_history.dart';
import 'student_profile.dart';

class StudentMain extends StatefulWidget {
  const StudentMain({super.key});

  @override
  State<StudentMain> createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {

  int currentIndex = 0;

  int? userId;
  String? token;

  /*
  =====================================
  LOAD USER SESSION (FROM STORAGE)
  =====================================
  */

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getInt("userId");
      token = prefs.getString("token");
    });
  }

  /*
  =====================================
  PAGES (BOTTOM NAVIGATION)
  =====================================
  */

  List<Widget> get pages {

    /*
    While loading user session
    */
    if (userId == null || token == null) {
      return [
        const Center(child: CircularProgressIndicator()),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
      ];
    }

    return [

      /*
      DASHBOARD (API CONNECTED)
      */
      StudentDashboard(
        userId: userId!,
        token: token!,
      ),

      /*
      COURSES PAGE
      */
      const MyCourses(),

      /*
      ATTENDANCE HISTORY
      */
      const AttendanceHistory(),

      /*
      PROFILE PAGE
      */
      const StudentProfile(),
    ];
  }

  /*
  =====================================
  UI
  =====================================
  */

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        selectedItemColor: const Color(0xFFF4A300),

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard , color: Color(0xFF034D08)),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.book , color: Color(0xFF034D08)),
            label: "Courses",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Color(0xFF034D08)),
            label: "History",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person , color: Color(0xFF034D08)),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}