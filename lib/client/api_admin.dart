import 'dart:convert';
import 'package:http/http.dart' as http;
// Adjust this import based on where your ApiClient (which holds baseUrl) is located
import 'api_client.dart';

class ApiAdmin {
  // Fetch all users
  Future<Map<String, dynamic>> fetchAllUsers(String token) async {
    final url = Uri.parse('${ApiClient.baseUrl}/admin/users');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot connect to server: ${e.toString()}',
      };
    }
  }

  // Update a specific user
  // Update a specific user
  Future<Map<String, dynamic>> updateUser(
    String token,
    int userId,
    String name,
    String email,
    String status,
  ) async {
    final url = Uri.parse('${ApiClient.baseUrl}/admin/users/$userId');
    final bodyPayload = jsonEncode({
      'name': name,
      'email': email,
      'status_akun': status,
    });

    // --- DEBUG LOGGING ---
    print('--- ADMIN UPDATE REQUEST ---');
    print('URL: $url');
    print('Payload: $bodyPayload');
    // ----------------------

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: bodyPayload,
      );

      // --- DEBUG LOGGING ---
      print('--- ADMIN UPDATE RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      // ----------------------

      return jsonDecode(response.body);
    } catch (e) {
      print('--- ADMIN UPDATE EXCEPTION ---');
      print(e.toString());
      return {
        'success': false,
        'message': 'Cannot connect to server: ${e.toString()}',
      };
    }
  }
}
