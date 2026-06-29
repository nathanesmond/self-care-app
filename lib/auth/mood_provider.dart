import 'package:flutter/material.dart';
import '../client/api_mood.dart';

class MoodProvider extends ChangeNotifier {
  final ApiMood _apiMood = ApiMood();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> uploadDailyMood({
    required String token,
    required int skorMood,
    required String mood,
    required List<String> influences,
    required String notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiMood.executeLogMood(
      token: token,
      skorMood: skorMood,
      mood: mood,
      influences: influences,
      notes: notes,
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
