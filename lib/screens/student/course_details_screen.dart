import 'package:flutter/material.dart';

class CourseDetailsScreen extends StatelessWidget {

  final String courseCode;
  final String courseTitle;
  final String lecturerName;

  const CourseDetailsScreen({
    super.key,
    required this.courseCode,
    required this.courseTitle,
    required this.lecturerName,
  });

  static const Color primaryGreen = Color(0xFF034D08);
  static const Color primaryOrange = Color(0xFFF4A300);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Course Details"),
        backgroundColor: primaryGreen,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /*
            COURSE CARD
            */

            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      courseCode,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      courseTitle,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Lecturer: $lecturerName",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Course Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "• Attendance records will be shown here\n"
                  "• Session history\n"
                  "• More features coming...",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
//
// class CourseDetailsScreen extends StatelessWidget {
//   const CourseDetailsScreen({super.key});
//
//   static const Color primaryGreen = Color(0xFF034D08);
//   static const Color primaryOrange = Color(0xFFF4A300);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Course Details"),
//         backgroundColor: primaryGreen,
//       ),
//
//       backgroundColor: Colors.grey[100],
//
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//
//           children: [
//
//             /// COURSE CARD
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//
//               child: const Padding(
//                 padding: EdgeInsets.all(16),
//
//                 child: Column(
//
//                   children: [
//
//                     ListTile(
//                       leading: Icon(Icons.book, color: primaryGreen),
//                       title: Text(
//                         "Course",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text("CSC301 - Computer Networks"),
//                     ),
//
//                     Divider(),
//
//                     ListTile(
//                       leading: Icon(Icons.person, color: primaryGreen),
//                       title: Text(
//                         "Lecturer",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text("Dr Ahmed"),
//                     ),
//
//                     Divider(),
//
//                     ListTile(
//                       leading: Icon(Icons.schedule, color: primaryGreen),
//                       title: Text(
//                         "Schedule",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text("Monday 10:00 AM"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             /// ATTENDANCE SUMMARY
//             const Text(
//               "Attendance Summary",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: primaryGreen,
//               ),
//             ),
//
//             const SizedBox(height: 15),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//               children: const [
//
//                 Column(
//                   children: [
//                     Text(
//                       "10",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: primaryGreen,
//                       ),
//                     ),
//                     Text("Present"),
//                   ],
//                 ),
//
//                 Column(
//                   children: [
//                     Text(
//                       "2",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: primaryOrange,
//                       ),
//                     ),
//                     Text("Late"),
//                   ],
//                 ),
//
//                 Column(
//                   children: [
//                     Text(
//                       "1",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                     ),
//                     Text("Absent"),
//                   ],
//                 ),
//
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }