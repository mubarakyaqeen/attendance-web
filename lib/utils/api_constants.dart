class ApiConstants {

  static const String baseUrl = "https://attendance-system-2c1j.onrender.com";

  /// AUTH
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";

  /// LECTURER
  static const String createCourse = "$baseUrl/lecturer/courses";

  /// STUDENT
  static const String studentDashboard = "$baseUrl/student/dashboard";

  /// ADMIN
  static const String createStudent = "$baseUrl/admin/students";
  static const String departments = "$baseUrl/admin/departments";
}