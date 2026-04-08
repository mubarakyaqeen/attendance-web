import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'courses_page.dart';
import 'attendance_summary_page.dart';

class LecturerHome extends StatefulWidget {

  final int lecturerId;
  final String token;

  const LecturerHome({
    super.key,
    required this.lecturerId,
    required this.token,
  });

  @override
  State<LecturerHome> createState() => _LecturerHomeState();
}

class _LecturerHomeState extends State<LecturerHome> {

  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [

      /// Dashboard
      DashboardPage(
        lecturerId: widget.lecturerId,
        token: widget.token,
      ),

      /// Courses
      CoursesPage(
        lecturerId: widget.lecturerId,
        token: widget.token,
      ),

      /// Attendance Summary
      AttendanceSummaryPage(
        lecturerId: widget.lecturerId,
        token: widget.token,
      ),

    ];
  }

  void _onItemTapped(int index) {

    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _selectedIndex,

        onTap: _onItemTapped,

        selectedItemColor: const Color(0xFF034D08),

        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Courses",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Attendance",
          ),

        ],
      ),
    );
  }
}