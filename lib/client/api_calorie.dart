import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ApiCalorie {
  Future<Map<String, dynamic>> executeLogCalorie({
    required String token,
    required String namaMakanan,
    required int jumlahKalori,
    required String mealType,
    required String loggedTime,
    required String logDate,
  }) async {
    final url = Uri.parse('${ApiClient.baseUrl}/calorie-log');

    try {
      final response = await http.post(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'nama_makanan': namaMakanan,
          'jumlah_kalori': jumlahKalori,
          'meal_type': mealType,
          'logged_time': loggedTime,
          'log_date': logDate,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to server.'};
    }
  }

  Future<Map<String, dynamic>> executeFetchDailyLogs(
    String token,
    String date,
  ) async {
    final url = Uri.parse('${ApiClient.baseUrl}/calorie-daily?date=$date');

    try {
      final response = await http.get(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Failed to fetch data from server.'};
    }
  }

  Future<Map<String, dynamic>> executeDeleteCalorie(
    String token,
    int idCalorieLog,
  ) async {
    final url = Uri.parse('${ApiClient.baseUrl}/calorie-log/$idCalorieLog');

    try {
      final response = await http.delete(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to server.'};
    }
  }
}
