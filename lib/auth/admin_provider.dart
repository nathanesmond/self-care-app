import 'package:flutter/material.dart';
import '../client/api_admin.dart';

class AdminProvider with ChangeNotifier {
  final ApiAdmin _apiAdmin = ApiAdmin();

  List<dynamic> _users = [];
  bool _isLoading = false;

  List<dynamic> get users => _users;
  bool get isLoading => _isLoading;

  // Load all users from the API
  Future<void> loadUsers(String token) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiAdmin.fetchAllUsers(token);

    if (result['success'] == true) {
      _users = result['users'] ?? [];
    } else {
      _users = [];
      print("Error loading users: ${result['message']}");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Edit a user and update the local list if successful
  Future<Map<String, dynamic>> editUser(
    String token,
    int userId,
    String name,
    String email,
    String status,
  ) async {
    final result = await _apiAdmin.updateUser(
      token,
      userId,
      name,
      email,
      status,
    );

    if (result['success'] == true) {
      // Find the user in our local list and update their data immediately
      // so the UI refreshes without needing another full API call.
      final index = _users.indexWhere((u) => u['id_user'] == userId);
      if (index != -1) {
        _users[index]['name'] = name;
        _users[index]['email'] = email;
        _users[index]['status_akun'] = status;
        notifyListeners();
      }
      return {'success': true, 'message': result['message']};
    } else {
      // Handle validation errors or server errors
      String errorMsg = result['message'] ?? 'Failed to update user';
      if (result['errors'] != null) {
        errorMsg =
            result['errors'].values.first[0]; // Grab the first validation error
      }
      return {'success': false, 'message': errorMsg};
    }
  }

  void clearState() {
    _users = [];
    _isLoading = false;
    notifyListeners();
  }
}
