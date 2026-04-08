import 'package:flutter/material.dart';
import 'package:student_attendance_app/models/course_model.dart';
import '../../models/department_model.dart';
import '../../service/auth_service.dart';
import '../../service/course_service.dart';
import '../../service/student_service.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {

  final TextEditingController courseCodeController = TextEditingController();
  final TextEditingController courseTitleController = TextEditingController();

  String level = "ND1";
  String semester = "First Semester";

  bool loadingDepartments = true;

  List<Department> departments = [];
  Department? selectedDepartment;

  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  /*
  Fetch departments from backend
  */

  Future<void> loadDepartments() async {

    try {

      final result = await StudentService.getDepartments();

      setState(() {
        departments = result;
        loadingDepartments = false;
      });

    } catch (e) {

      setState(() {
        loadingDepartments = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load departments")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create Course"),
        backgroundColor: const Color(0xFF034D08),
      ),

      backgroundColor: const Color(0xFFF4F6F8),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// COURSE CODE
            const Text(
              "Course Code",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            TextField(
              controller: courseCodeController,
              decoration: InputDecoration(
                hintText: "CSC301",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// COURSE TITLE
            const Text(
              "Course Title",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            TextField(
              controller: courseTitleController,
              decoration: InputDecoration(
                hintText: "Computer Networks",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// DEPARTMENT (FROM DATABASE)

            const Text(
              "Department",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            loadingDepartments
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<Department>(

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

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LEVEL

            const Text(
              "Level",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            DropdownButtonFormField(

              value: level,

              items: const [

                DropdownMenuItem(value: "ND1", child: Text("ND1")),
                DropdownMenuItem(value: "ND2", child: Text("ND2")),
                DropdownMenuItem(value: "HND1", child: Text("HND1")),
                DropdownMenuItem(value: "HND2", child: Text("HND2")),

              ],

              onChanged: (value) {
                setState(() {
                  level = value!;
                });
              },

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// SEMESTER

            const Text(
              "Semester",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            DropdownButtonFormField(

              value: semester,

              items: const [

                DropdownMenuItem(
                  value: "First Semester",
                  child: Text("First Semester"),
                ),

                DropdownMenuItem(
                  value: "Second Semester",
                  child: Text("Second Semester"),
                ),

              ],

              onChanged: (value) {
                setState(() {
                  semester = value!;
                });
              },

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF034D08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed: () async {

                  String code = courseCodeController.text.trim();
                  String title = courseTitleController.text.trim();

                  if (code.isEmpty || title.isEmpty || selectedDepartment == null) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all fields"),
                      ),
                    );

                    return;
                  }

                  int? lecturerId = await AuthService().getLecturerId();

                  if (lecturerId == null) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lecturer profile not found"),
                      ),
                    );

                    return;
                  }

                  try {

                    final token = await AuthService().getToken();

                    await CourseService.createCourse(
                      code: code,
                      name: title,
                      lecturerId: lecturerId,
                      departmentId: selectedDepartment!.id,
                      level: level,
                      token: token!,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Course created successfully"),
                      ),
                    );

                    Navigator.pop(context);

                  } catch (e) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to create course"),
                      ),
                    );

                  }

                },

                child: const Text(
                  "Save Course",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}