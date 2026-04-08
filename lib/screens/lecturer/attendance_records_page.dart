import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/api_constants.dart';

class AttendanceRecordsPage extends StatefulWidget {

  final int sessionId;
  final String token;

  const AttendanceRecordsPage({
    super.key,
    required this.sessionId,
    required this.token,
  });

  @override
  State<AttendanceRecordsPage> createState() => _AttendanceRecordsPageState();
}

class _AttendanceRecordsPageState extends State<AttendanceRecordsPage> {

  List records = [];
  bool loading = true;

  final TextEditingController searchController = TextEditingController();

  Future<void> fetchRecords() async {

    try {

      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/lecturer/session/${widget.sessionId}/records",
        ),
        headers: {
          "Authorization": "Bearer ${widget.token}"
        },
      );

      if (response.statusCode == 200) {

        if(response.body.isEmpty){
          setState(() {
            records = [];
            loading = false;
          });
          return;
        }

        final data = jsonDecode(response.body);

        setState(() {
          records = data;
          loading = false;
        });

      } else {

        setState(() {
          loading = false;
        });

      }

    } catch (e) {

      print("Records error: $e");

      setState(() {
        loading = false;
      });

    }

  }

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Attendance Records"),
        backgroundColor: const Color(0xFF034D08),
      ),

      backgroundColor: const Color(0xFFF4F6F8),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// SEARCH FIELD
            TextField(
              controller: searchController,
              onChanged: (value){
                setState(() {});
              },

              decoration: InputDecoration(
                hintText: "Search Student",
                prefixIcon: const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// EMPTY STATE
            if(records.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No attendance records found",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )

            else

            /// RECORD LIST
              Expanded(
                child: ListView.builder(

                  itemCount: records.length,

                  itemBuilder: (context, index) {

                    final record = records[index];

                    final student = record["student"];
                    final name = student?["name"] ?? "Unknown";
                    final status = record["status"] ?? "Absent";

                    if(searchController.text.isNotEmpty &&
                        !name.toLowerCase().contains(
                            searchController.text.toLowerCase())){
                      return const SizedBox();
                    }

                    return attendanceTile(
                      name: name,
                      status: status,
                    );

                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget attendanceTile({
    required String name,
    required String status,
  }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
          )
        ],
      ),

      child: ListTile(

        leading: const CircleAvatar(
          backgroundColor: Color(0xFF034D08),
          child: Icon(Icons.person, color: Colors.white),
        ),

        title: Text(name),

        trailing: Text(
          status,
          style: TextStyle(
            color: status == "Present"
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}