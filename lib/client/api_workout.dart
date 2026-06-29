import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ApiWorkout {
  Future<Map<String, dynamic>> executeFetchAiRecommendation(
    String token,
  ) async {
    final url = Uri.parse('${ApiClient.baseUrl}/workout/recommendation');
    try {
      final response = await http.get(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to server.'};
    }
  }

  Future<Map<String, dynamic>> executeToggleExercise(
    String token,
    int idExercise,
  ) async {
    final url = Uri.parse(
      '${ApiClient.baseUrl}/workout/exercise/toggle/$idExercise',
    );
    try {
      final response = await http.post(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to server.'};
    }
  }

  Future<Map<String, dynamic>> executeCompleteSession(
    String token,
    int idSession,
  ) async {
    final url = Uri.parse(
      '${ApiClient.baseUrl}/workout/session/complete/$idSession',
    );
    try {
      final response = await http.post(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to process with server.'};
    }
  }

  Future<Map<String, dynamic>> executeSkipSession(
    String token,
    int idSession,
  ) async {
    final url = Uri.parse(
      '${ApiClient.baseUrl}/workout/session/skip/$idSession',
    );
    try {
      final response = await http.post(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to process with server.'};
    }
  }

  Future<Map<String, dynamic>> executeFetchHistory(String token) async {
    final url = Uri.parse('${ApiClient.baseUrl}/history/dashboard');
    try {
      final response = await http.get(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to load history.'};
    }
  }

  Future<Map<String, dynamic>> executeGenerateTodayWorkout(String token) async {
    final url = Uri.parse('${ApiClient.baseUrl}/workout/generate');
    try {
      final response = await http.post(
        url,
        headers: {...ApiClient.baseHeaders, 'Authorization': 'Bearer $token'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to generate recommendation.',
      };
    }
  }
}
