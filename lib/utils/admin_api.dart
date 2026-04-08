import 'dart:convert';
import '../models/dashboard_model.dart';
import 'api_client.dart';

class AdminApi {

  static Future<DashboardModel?> getDashboardStats() async {

    final response = await ApiClient.get("/admin/dashboard");

    if(response.statusCode == 200){

      final data = jsonDecode(response.body);

      return DashboardModel.fromJson(data);

    }

    return null;

  }

}