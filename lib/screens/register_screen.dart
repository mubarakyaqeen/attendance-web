import 'package:flutter/material.dart';
import '../../models/department_model.dart';
import '../service/student_service.dart';
import 'admin/registration_blocked_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  String? selectedLevel;

  static const Color primaryGreen = Color(0xFF034D08);
  static const Color primaryOrange = Color(0xFFF4A300);

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final matricController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  bool isLoadingDepartments = true;
  bool isRegistering = false;

  List<Department> departments = [];
  Department? selectedDepartment;

  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  void loadDepartments() async {

    try {

      final data = await StudentService.getDepartments();

      setState(() {
        departments = data;
        isLoadingDepartments = false;
      });

    } catch (e) {

      setState(() {
        isLoadingDepartments = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load departments")),
      );

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
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2.5),
      ),
    );
  }

  /*
  Register student
  */

  void registerStudent() async {

    if (!_formKey.currentState!.validate()) return;

    if (selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select department")),
      );
      return;
    }

    if (selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select level")),
      );
      return;
    }



    setState(() {
      isRegistering = true;
    });

    try {

      await StudentService.registerStudent(

        fullName: nameController.text,
        matricNumber: matricController.text,
        email: emailController.text,
        password: passwordController.text,
        departmentId: selectedDepartment!.id,
        level: selectedLevel!,

      );


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful")),
      );

      Navigator.pop(context);

    } catch (e) {

      final error = e.toString();

      /// 🔥 NEW LOGIC (SAFE ADDITION)
      if (error.contains("REGISTRATION_BLOCKED")) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegistrationBlockedScreen(),
          ),
        );

      } else {

        /// ✅ KEEP YOUR OLD BEHAVIOR (but improved message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.replaceAll("Exception: ", ""),
            ),
          ),
        );
      }
    }

    setState(() {
      isRegistering = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: Form(

            key: _formKey,

            child: Column(

              children: [

                const SizedBox(height: 20),

                Image.asset(
                  "assets/images/yabatech_logo.png",
                  width: 90,
                ),

                const SizedBox(height: 15),

                const Text(
                  "Student Registration",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: nameController,
                  decoration: inputDecoration("Full Name", Icons.person),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Full name is required" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: matricController,
                  decoration: inputDecoration("Matric Number", Icons.badge),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Matric number is required" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  decoration: inputDecoration("Email", Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email is required";
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: inputDecoration("Password", Icons.lock).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility : Icons.visibility_off,
                        color: primaryGreen,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password is required";
                    if (value.length < 6) return "Minimum 6 characters";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                isLoadingDepartments
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<Department>(
                  decoration: inputDecoration("Department", Icons.business),
                  value: selectedDepartment,
                  items: departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDepartment = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? "Select department" : null,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: inputDecoration("Level", Icons.school),
                  value: selectedLevel,
                  items: ["ND1", "ND2", "HND1", "HND2"]
                      .map((level) => DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLevel = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? "Select level" : null,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isRegistering ? null : registerStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isRegistering
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "REGISTER",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}