import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ApiMood {
  Future<Map<String, dynamic>> executeLogMood({
    required String token,
    required int skorMood,
    required String mood,
    required List<String> influences,
    required String notes,
  }) async {
    final url = Uri.parse('${ApiClient.baseUrl}/mood-log');
    final String localDate = DateTime.now().toIso8601String().split('T')[0];
    try {
      final response = await http.post(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},

        body: jsonEncode({
          'skor_mood': skorMood,
          'mood': mood,
          'influences': influences,
          'notes': notes,
          'log_date': localDate,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to log daily mood.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to server: ${e.toString()}',
      };
    }
  }
}
