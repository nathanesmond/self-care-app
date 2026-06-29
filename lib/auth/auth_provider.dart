import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../client/api_user.dart';
import '../client/api_client.dart';
import '../entity/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiUser _apiUser = ApiUser();

  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiUser.executeLogin(email, password);

      if (result['success'] == true) {
        _token = result['access_token'];
        _currentUser = User.fromJson(result['user']);

        _isLoading = false;
        notifyListeners();

        // 🔥 FIX: Return the role from the API response so the UI can route correctly
        return {'success': true, 'role': result['user']['role']};
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': result['message'] ?? 'Login failed.',
        };
      }
      // ignore: unused_catch_stack
    } catch (e, stacktrace) {
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'message': 'Gagal memproses data masuk: Tipe data tidak sesuai ($e)',
      };
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiUser.executeRegister(email, password);

    if (result['success'] == true) {
      _token = result['access_token'];
      _currentUser = User.fromJson(result['user']);
      _isLoading = false;
      notifyListeners();
      return {'success': true};
    } else {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': result['message'] ?? 'Registration failed.',
      };
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    if (_token != null) {
      await _apiUser.executeLogout(_token!);
    }

    _token = null;
    _currentUser = null;
    _isLoading = false;

    notifyListeners();
  }

  Future<Map<String, dynamic>> submitOnboardingData(
    Map<String, dynamic> data,
  ) async {
    if (_token == null) {
      return {
        'success': false,
        'message': 'your session has expired. Please log in again.',
      };
    }

    _isLoading = true;
    notifyListeners();

    final result = await _apiUser.executeOnboarding(_token!, data);

    _isLoading = false;
    notifyListeners();

    if (result['success'] == true) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'message': result['message'] ?? 'Failed to save onboarding data.',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfileData(
    Map<String, dynamic> newPayload,
  ) async {
    if (_token == null)
      return {
        'success': false,
        'message': 'your session has expired. Please log in again.',
      };

    _isLoading = true;
    notifyListeners();

    final result = await _apiUser.executeUpdateProfile(_token!, newPayload);

    if (result['success'] == true && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        gender: newPayload['gender'],
        gymMembership: newPayload['gym_membership'],
      );
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get profileData => _profileData;

  Future<void> fetchProfileData() async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    final result = await _apiUser.executeGetProfile(_token!);

    if (result['success'] == true) {
      _profileData = result['data'] as Map<String, dynamic>;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiClient.baseUrl}/forgot-password/send-otp');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final result = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();

      return {
        'success': result['success'] ?? (response.statusCode == 200),
        'message': result['message'],
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Failed to connect to server.'};
    }
  }

  // Phase 2: Verify OTP and Reset
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiClient.baseUrl}/forgot-password/reset');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'otp': otp, 'password': newPassword}),
      );

      final result = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();

      return {
        'success': result['success'] ?? (response.statusCode == 200),
        'message': result['message'],
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Failed to connect to server.'};
    }
  }

  // --- EMAIL VERIFICATION ---
  Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiClient.baseUrl}/verify-email');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final result = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();

      return {
        'success': result['success'] ?? (response.statusCode == 200),
        'message': result['message'],
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Failed to connect to server.'};
    }
  }

  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      final url = Uri.parse('${ApiClient.baseUrl}/resend-verification');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      final result = jsonDecode(response.body);
      return {
        'success': result['success'] ?? (response.statusCode == 200),
        'message': result['message'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to server.'};
    }
  }

  // --- CHANGE EMAIL ---
  Future<Map<String, dynamic>> changeEmail(String newEmail) async {
    if (_token == null)
      return {'success': false, 'message': 'Not authenticated'};

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiClient.baseUrl}/change-email');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'new_email': newEmail}),
      );

      final result = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();

      return {
        'success': result['success'] ?? (response.statusCode == 200),
        'message': result['message'],
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Failed to connect to server.'};
    }
  }
}
