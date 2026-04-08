import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/api_client.dart';

class EditLecturer extends StatefulWidget {

  final Map lecturer;

  const EditLecturer({super.key, required this.lecturer});

  @override
  State<EditLecturer> createState() => _EditLecturerState();
}

class _EditLecturerState extends State<EditLecturer> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  List departments = [];
  int? selectedDepartment;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.lecturer["fullName"];
    emailController.text = widget.lecturer["email"];

    loadDepartments();
  }

  Future<void> loadDepartments() async {

    final response = await ApiClient.get("/admin/departments");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      setState(() {
        departments = data;
      });

    }
  }

  Future<void> updateLecturer() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    final response = await ApiClient.put(
      "/admin/lecturers/${widget.lecturer["id"]}",
      {
        "fullName": nameController.text,
        "email": emailController.text,
        "password": "",
        "departmentId": selectedDepartment
      },
    );

    setState(() {
      loading = false;
    });

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lecturer updated")),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Lecturer"),
        backgroundColor: const Color(0xFF034D08),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              /// NAME
              TextFormField(
                controller: nameController,

                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),

                validator: (value) =>
                value!.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 20),

              /// EMAIL
              TextFormField(
                controller: emailController,

                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),

                validator: (value) =>
                value!.isEmpty ? "Enter email" : null,
              ),

              const SizedBox(height: 20),

              /// DEPARTMENT
              DropdownButtonFormField<int>(

                value: selectedDepartment,

                items: departments.map<DropdownMenuItem<int>>((dept) {

                  return DropdownMenuItem<int>(
                    value: dept["id"],
                    child: Text(dept["name"]),
                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {
                    selectedDepartment = value;
                  });

                },

                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),

              ),

              const SizedBox(height: 30),

              /// UPDATE BUTTON
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  onPressed: loading ? null : updateLecturer,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF034D08),
                  ),

                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Lecturer"),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}