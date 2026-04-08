import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/api_client.dart';

class AddLecturer extends StatefulWidget {
  const AddLecturer({super.key});

  @override
  State<AddLecturer> createState() => _AddLecturerState();
}

class _AddLecturerState extends State<AddLecturer> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  List departments = [];
  int? selectedDepartment;

  bool loading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> createLecturer() async {

    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    final response = await ApiClient.post(
      "/admin/lecturers",
      {
        "fullName": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "departmentId": selectedDepartment
      },
    );

    setState(() {
      loading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lecturer created successfully")),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create lecturer")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Lecturer"),
        backgroundColor: const Color(0xFF034D08),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              /// FULL NAME
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Enter full name" : null,
              ),

              const SizedBox(height: 20),

              /// EMAIL
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Enter email" : null,
              ),

              const SizedBox(height: 20),

              /// PHONE
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// DEPARTMENT DROPDOWN
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
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),

                validator: (value) =>
                value == null ? "Select department" : null,
              ),

              const SizedBox(height: 20),

              /// PASSWORD
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Enter password" : null,
              ),

              const SizedBox(height: 20),

              /// CONFIRM PASSWORD
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Confirm password" : null,
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  onPressed: loading ? null : createLecturer,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF034D08),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),

                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Create Lecturer",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}