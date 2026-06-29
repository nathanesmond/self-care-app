import 'package:flutter/material.dart';
import '../client/api_calorie.dart';
import '../entity/calorie_log_item.dart';
import '../services/offline_calorie_service.dart';

class CalorieProvider extends ChangeNotifier {
  final ApiCalorie _apiCalorie = ApiCalorie();

  List<CalorieLogItem> _dailyLogs = [];
  int _totalConsumed = 0;
  bool _isLoading = false;
  int _targetCalorie = 2100;

  List<CalorieLogItem> get dailyLogs => _dailyLogs;
  int get totalConsumed => _totalConsumed;
  bool get isLoading => _isLoading;
  int get targetCalorie => _targetCalorie;

  Future<void> fetchDailyCalories(String token, String date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiCalorie.executeFetchDailyLogs(token, date);

      if (result['success'] == true) {
        _totalConsumed = result['total_consumed'] as int;

        _targetCalorie = result['target_calorie'] ?? 2100;

        final List<dynamic> logData = result['logs'];

        _dailyLogs = logData
            .map((json) => CalorieLogItem.fromJson(json))
            .toList();

        for (var log in logData) {
          await OfflineCalorieService.instance.insertLocalCalorie(
            namaMakanan: log['nama_makanan'] ?? 'Makanan',
            jumlahKalori: int.tryParse(log['jumlah_kalori'].toString()) ?? 0,
            logDate: date,
            isSynced: 1,
          );
        }
      }
    } catch (e) {
      print("OFFLINE MODE: Failed to fetch daily calories...");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> storeCalorieLog({
    required String token,
    required String name,
    required int calories,
    required String mealType,
    required String time,
    required String date,
  }) async {
    try {
      final result = await _apiCalorie.executeLogCalorie(
        token: token,
        namaMakanan: name,
        jumlahKalori: calories,
        mealType: mealType,
        loggedTime: time,
        logDate: date,
      );

      if (result['success'] == true) {
        await OfflineCalorieService.instance.insertLocalCalorie(
          namaMakanan: name,
          jumlahKalori: calories,
          logDate: date,
          isSynced: 1,
        );

        await fetchDailyCalories(token, date);
        return {'success': true, 'offline': false};
      }
      return {'success': false, 'message': result['message']};
    } catch (e) {
      print(
        "OFFLINE MODE: Failed to log calorie to server. Saving locally... ($e)",
      );

      await OfflineCalorieService.instance.insertLocalCalorie(
        namaMakanan: name,
        jumlahKalori: calories,
        logDate: date,
        isSynced: 0,
      );

      await fetchDailyCalories(token, date);

      return {
        'success': true,
        'offline': true,
        'message': 'Data saved locally. Will sync automatically when online.',
      };
    }
  }

  Future<void> syncOfflineDataToServer(String token) async {
    final unsyncedLogs = await OfflineCalorieService.instance
        .getUnsyncedCalories();
    if (unsyncedLogs.isEmpty) return;

    print(
      "Found ${unsyncedLogs.length} unsynced log(s). Attempting to sync...",
    );

    for (var log in unsyncedLogs) {
      try {
        final result = await _apiCalorie.executeLogCalorie(
          token: token,
          namaMakanan: log['nama_makanan'],
          jumlahKalori: log['jumlah_kalori'],
          mealType: 'Snack',
          loggedTime: '00:00',
          logDate: log['log_date'],
        );

        if (result['success'] == true) {
          await OfflineCalorieService.instance.markAsSynced(log['id']);
          print("Successfully synced local ID ${log['id']} to server.");
        }
      } catch (e) {
        print(
          "OFFLINE MODE: Failed to sync local log ID ${log['id']} to server. Will retry later... ($e)",
        );
        break;
      }
    }
  }

  Future<Map<String, dynamic>> deleteCalorieLog(
    String token,
    int idCalorieLog,
    String date,
  ) async {
    try {
      final result = await _apiCalorie.executeDeleteCalorie(
        token,
        idCalorieLog,
      );

      if (result['success'] == true) {
        await fetchDailyCalories(token, date);
        return {'success': true};
      }
      return {'success': false, 'message': result['message']};
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot delete log items while offline.',
      };
    }
  }
}
