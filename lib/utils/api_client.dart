import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {

  static const String baseUrl = "https://attendance-system-2c1j.onrender.com";

  /// =========================
  /// TOKEN MANAGEMENT
  /// =========================

  /// Save token after login
  static Future<void> saveToken(String token) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);

  }

  /// Get token
  static Future<String?> getToken() async {

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");

  }

  /// Clear token (Logout)
  static Future<void> clearToken() async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

  }

  /// =========================
  /// GET request with token
  /// =========================

  static Future<http.Response> get(String endpoint) async {

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    return http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
  }

  /// =========================
  /// POST request with token
  /// =========================

  static Future<http.Response> post(
      String endpoint,
      Map<String, dynamic> data
      ) async {

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    return http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(data),
    );
  }

  /// =========================
  /// PUT request
  /// =========================

  static Future<http.Response> put(
      String endpoint,
      Map<String, dynamic> data
      ) async {

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    return http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(data),
    );
  }

  /// =========================
  /// DELETE request
  /// =========================

  static Future<http.Response> delete(String endpoint) async {

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    return http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
  }

}