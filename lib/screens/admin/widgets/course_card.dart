import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String code;
  final String title;
  final String lecturer;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCard({
    super.key,
    required this.code,
    required this.title,
    required this.lecturer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(

        leading: const CircleAvatar(
          backgroundColor: Color(0xFF034D08),
          child: Icon(Icons.book, color: Colors.white),
        ),

        title: Text("$code - $title"),

        subtitle: Text("Lecturer: $lecturer"),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),

          ],
        ),
      ),
    );
  }
}