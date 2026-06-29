import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ApiUser {
  Future<Map<String, dynamic>> executeLogin(
    String email,
    String password,
  ) async {
    final url = Uri.parse('${ApiClient.baseUrl}/login');

    final bodyPayload = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(
        url,
        headers: ApiClient.baseHeaders,
        body: bodyPayload,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot connect to server: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> executeRegister(
    String email,
    String password,
  ) async {
    final url = Uri.parse('${ApiClient.baseUrl}/register');

    final bodyPayload = jsonEncode({
      'email': email,
      'password': password,
      'id_role': 2,
    });

    try {
      final response = await http.post(
        url,
        headers: ApiClient.baseHeaders,
        body: bodyPayload,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot connect to server: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> executeLogout(String token) async {
    final url = Uri.parse('${ApiClient.baseUrl}/logout');

    try {
      final response = await http.post(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': 'Failed to delete session from server.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to server: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> executeOnboarding(
    String token,
    Map<String, dynamic> surveyData,
  ) async {
    final url = Uri.parse('${ApiClient.baseUrl}/onboarding');

    try {
      final response = await http.post(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
        body: jsonEncode(surveyData),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to server: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> executeUpdateProfile(
    String token,
    Map<String, dynamic> updatedData,
  ) async {
    final url = Uri.parse('${ApiClient.baseUrl}/profile');

    try {
      final response = await http.put(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
        body: jsonEncode(updatedData),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to server: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> executeGetProfile(String token) async {
    final url = Uri.parse('${ApiClient.baseUrl}/profile');

    try {
      final response = await http.get(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch profile data: ${e.toString()}',
      };
    }
  }
}
