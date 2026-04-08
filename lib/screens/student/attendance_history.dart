import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/attendance_history_model.dart';
import '../../service/student_service.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {

  List<AttendanceHistoryModel> records = [];
  bool loading = true;
  String? error;

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt("userId");
      final token = prefs.getString("token");

      if (userId == null || token == null) {
        throw Exception("User session not found");
      }

      final data = await StudentService.getAttendanceHistory(userId, token);

      safeSetState(() {
        records = data;
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


  // Future<void> loadHistory() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     final userId = prefs.getInt("userId");
  //     final token = prefs.getString("token");
  //
  //     if (userId == null || token == null) {
  //       throw Exception("User session not found");
  //     }
  //
  //     final data = await StudentService.getAttendanceHistory(userId, token);
  //
  //     setState(() {
  //       records = data;
  //       loading = false;
  //     });
  //
  //   } catch (e) {
  //     setState(() {
  //       error = e.toString();
  //       loading = false;
  //     });
  //   }
  // }

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

    return Scaffold(

      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: const Color(0xFF034D08),
      ),

      body: records.isEmpty
          ? const Center(child: Text("No attendance records"))
          : ListView(

        children: records.map((record) {

          final time = DateTime.parse(record.markedAt);

          return ListTile(

            leading: const Icon(
              Icons.check_circle,
              color: Color(0xFF034D08),
              size: 32,
            ),

            title: Text(
              record.courseCode,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            subtitle: Text(
              "${record.status} - ${time.hour}:${time.minute}",
            ),
          );

        }).toList(),
      ),
    );
  }
}