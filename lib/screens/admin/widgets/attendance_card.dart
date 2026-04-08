import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final String course;
  final String lecturer;
  final String date;
  final int present;
  final int absent;
  final String location;
  final bool active;

  const AttendanceCard({
    super.key,
    required this.course,
    required this.lecturer,
    required this.date,
    required this.present,
    required this.absent,
    required this.location,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Text(
                  course,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: active ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    active ? "ACTIVE" : "CLOSED",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text("Lecturer: $lecturer"),
            Text("Date: $date"),
            Text("Location: $location"),

            const SizedBox(height: 10),

            Row(
              children: [

                Text(
                  "Present: $present",
                  style: const TextStyle(color: Colors.green),
                ),

                const SizedBox(width: 20),

                Text(
                  "Absent: $absent",
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}