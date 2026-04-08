import 'package:flutter/material.dart';

import '../../service/department_service.dart';

class CreateDepartmentPage extends StatefulWidget {
  const CreateDepartmentPage({super.key});

  @override
  State<CreateDepartmentPage> createState() => _CreateDepartmentPageState();
}

class _CreateDepartmentPageState extends State<CreateDepartmentPage> {

  final TextEditingController nameController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Department"),
        backgroundColor: const Color(0xFF034D08),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Department Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : createDepartment,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Department"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createDepartment() async {

    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter department name")),
      );
      return;
    }

    setState(() => loading = true);

    try {

      await DepartmentService.createDepartment(name);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Department created successfully")),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create department")),
      );

    } finally {
      setState(() => loading = false);
    }
  }
}