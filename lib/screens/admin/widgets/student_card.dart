import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String matric;
  final String department;
  final bool blocked;

  final VoidCallback onBlock;
  final VoidCallback onDelete;

  const StudentCard({
    super.key,
    required this.name,
    required this.matric,
    required this.department,
    required this.blocked,
    required this.onBlock,
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
          child: Icon(Icons.school, color: Colors.white),
        ),

        title: Text(name),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Matric: $matric"),
            Text("Department: $department"),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            IconButton(
              icon: Icon(
                blocked ? Icons.lock_open : Icons.block,
                color: blocked ? Colors.green : Colors.orange,
              ),
              onPressed: onBlock,
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