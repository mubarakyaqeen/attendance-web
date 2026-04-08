import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constants.dart';
import '../models/user_model.dart';

class AuthService {

  Future<User?> login(String email, String password) async {

    print("EMAIL SENT: $email");
    print("PASSWORD SENT: $password");

    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      print("Decoded Login Data: $data");

      User user = User.fromJson(data);

      if (user.token.isEmpty) {
        print("Login failed: token missing");
        return null;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setInt("userId", user.id);

      print("Saved UserID in storage: ${user.id}");

      await prefs.setString("role", user.role);
      await prefs.setString("name", user.name);
      await prefs.setString("token", user.token);

      if (user.lecturerId != null) {
        await prefs.setInt("lecturerId", user.lecturerId!);
      }

      print("LOGIN SUCCESS");
      print("User ID: ${user.id}");
      print("Lecturer ID: ${user.lecturerId}");
      print("Role: ${user.role}");
      print("Name: ${user.name}");

      return user;

    } else {

      print("LOGIN FAILED");

      return null;
    }
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }



  Future<int?> getLecturerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("lecturerId");
  }

  Future<String?> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  Future<String?> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("name");
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


}














// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../utils/api_constants.dart';
// import '../models/user_model.dart';
//
// class AuthService {
//
//   /*
//    * Login user
//    * Works for Admin, Lecturer and Student
//    */
//   Future<User?> login(String email, String password) async {
//
//     print("EMAIL SENT: $email");
//     print("PASSWORD SENT: $password");
//
//     final response = await http.post(
//       Uri.parse(ApiConstants.login),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "email": email,
//         "password": password
//       }),
//     );
//
//     print("STATUS: ${response.statusCode}");
//     print("BODY: ${response.body}");
//
//     if (response.statusCode == 200) {
//
//       final data = jsonDecode(response.body);
//
//       User user = User.fromJson(data);
//
//       /*
//        * Save session locally
//        */
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       await prefs.setInt("userId", user.id);
//       await prefs.setString("role", user.role);
//       await prefs.setString("name", user.name);
//       await prefs.setString("token", user.token);
//
//       /*
//        * Optional if you use JWT
//        */
//       if (data["token"] != null) {
//         await prefs.setString("token", data["token"]);
//       }
//
//       return user;
//
//     } else {
//       return null;
//     }
//   }
//
//   /*
//    * Get stored userId
//    */
//   Future<int?> getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getInt("userId");
//   }
//
//   /*
//    * Get stored role
//    */
//   Future<String?> getRole() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString("role");
//   }
//
//   /*
//    * Get stored name
//    */
//   Future<String?> getName() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString("name");
//   }
//
//   /*
//    * Logout user
//    */
//   Future<void> logout() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }