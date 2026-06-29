import 'package:flutter/material.dart';
import '../client/api_workout.dart';
import '../services/offline_calorie_service.dart';

class HistoryProvider extends ChangeNotifier {
  final ApiWorkout _apiWorkout = ApiWorkout();

  Map<String, dynamic>? _overviewData;
  Map<String, dynamic>? _detailsData;
  bool _isLoading = false;

  Map<String, dynamic>? get overviewData => _overviewData;
  Map<String, dynamic>? get detailsData => _detailsData;
  bool get isLoading => _isLoading;

  void clearState() async {
    _overviewData = null;
    _detailsData = null;
    _isLoading = false;

    print("[HISTORY] Clearing history state and local cache due to logout.");
    await OfflineCalorieService.instance.clearLocalTable();

    notifyListeners();
  }

  Future<void> fetchHistoryData(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiWorkout.executeFetchHistory(token);

      if (result['success'] == true) {
        _overviewData = result['data']['overview'];
        _detailsData = result['data']['details'];
      }
    } catch (e) {
      print("[HISTORY] Failed to fetch history data from server. Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
