import 'package:flutter/material.dart';

class LecturerCard extends StatelessWidget {
  final String name;
  final String department;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LecturerCard({
    super.key,
    required this.name,
    required this.department,
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
          child: Icon(Icons.person, color: Colors.white),
        ),

        title: Text(name),
        subtitle: Text(department),

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