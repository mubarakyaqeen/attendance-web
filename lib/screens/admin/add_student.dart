import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/api_client.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {

  static const Color primaryGreen = Color(0xFF034D08);
  static const Color primaryOrange = Color(0xFFF4A300);

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final matricController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  List departments = [];
  int? selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  Future<void> loadDepartments() async {

    final response = await ApiClient.get("/admin/departments");

    if(response.statusCode == 200){

      setState(() {
        departments = jsonDecode(response.body);
      });

    }
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryGreen),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
    );
  }

  Future<void> registerStudent() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    final response = await ApiClient.post(
      "/admin/students",
      {
        "fullName": nameController.text,
        "matricNumber": matricController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "departmentId": selectedDepartmentId
      },
    );

    setState(() {
      loading = false;
    });

    if(response.statusCode == 200 || response.statusCode == 201){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student Registered Successfully")),
      );

      Navigator.pop(context);

    }else{

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to register student")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Student"),
        backgroundColor: primaryGreen,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              const SizedBox(height: 20),

              Image.asset(
                "assets/images/yabatech_logo.png",
                width: 80,
              ),

              const SizedBox(height: 20),

              const Text(
                "Student Registration",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(height: 30),

              /// FULL NAME
              TextFormField(
                controller: nameController,
                decoration: inputDecoration("Full Name", Icons.person),

                validator: (value) {
                  if(value == null || value.isEmpty){
                    return "Full name is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// MATRIC NUMBER
              TextFormField(
                controller: matricController,
                decoration: inputDecoration("Matric Number", Icons.badge),

                validator: (value) {
                  if(value == null || value.isEmpty){
                    return "Matric number is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// EMAIL
              TextFormField(
                controller: emailController,
                decoration: inputDecoration("Email", Icons.email),

                validator: (value) {

                  if(value == null || value.isEmpty){
                    return "Email is required";
                  }

                  if(!RegExp(r'\S+@\S+\.\S+').hasMatch(value)){
                    return "Enter a valid email";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// PASSWORD
              TextFormField(
                controller: passwordController,
                obscureText: hidePassword,

                decoration: inputDecoration("Password", Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: primaryGreen,
                    ),
                    onPressed: (){
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),

                validator: (value) {

                  if(value == null || value.isEmpty){
                    return "Password is required";
                  }

                  if(value.length < 6){
                    return "Password must be at least 6 characters";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// DEPARTMENT DROPDOWN
              DropdownButtonFormField<int>(

                value: selectedDepartmentId,
                hint: const Text("Select Department"),

                items: departments.map<DropdownMenuItem<int>>((dept){

                  return DropdownMenuItem<int>(
                    value: dept["id"],
                    child: Text(dept["name"]),
                  );

                }).toList(),

                onChanged: (value){

                  setState(() {
                    selectedDepartmentId = value;
                  });

                },

                validator: (value){

                  if(value == null){
                    return "Department is required";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              /// REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  onPressed: loading ? null : registerStudent,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "REGISTER",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}