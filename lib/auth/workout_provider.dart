import 'package:flutter/material.dart';
import '../client/api_workout.dart';

class WorkoutProvider extends ChangeNotifier {
  final ApiWorkout _apiWorkout = ApiWorkout();

  Map<String, dynamic>? _activeSession;
  List<String> _adaptations = [];
  bool _isLoading = false;
  bool _hasFetched = false;
  String? _loadedToken;

  Map<String, dynamic>? get activeSession => _activeSession;
  List<String> get adaptations => _adaptations;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;

  Future<void> initializeForUser(String token) async {
    if (_loadedToken != token || !_hasFetched) {
      _loadedToken = token;
      _isLoading = true;
      notifyListeners();

      final result = await _apiWorkout.executeFetchAiRecommendation(token);

      if (result['success'] == true &&
          result['weekly_plan'] != null &&
          (result['weekly_plan'] as List).isNotEmpty) {
        _activeSession = result['weekly_plan'][0];
        _adaptations = List<String>.from(result['ai_adaptations'] ?? []);
      } else {
        _activeSession = null;
        _adaptations = [];
      }

      _hasFetched = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateTodayWorkout(String token) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiWorkout.executeGenerateTodayWorkout(token);

    if (result['success'] == true &&
        result['weekly_plan'] != null &&
        (result['weekly_plan'] as List).isNotEmpty) {
      _activeSession = result['weekly_plan'][0];
      _adaptations = List<String>.from(result['ai_adaptations'] ?? []);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleExerciseCheckLocal(
    String token,
    int idExercise,
    int index,
  ) async {
    if (_activeSession == null) return;

    if (_activeSession!['status'] != 'pending') {
      print(
        "[WORKOUT] Cannot toggle exercise because session status is '${_activeSession!['status']}'",
      );
      return;
    }

    bool currentStatus = _activeSession!['exercises'][index]['is_done'] == 1;
    _activeSession!['exercises'][index]['is_done'] = currentStatus ? 0 : 1;
    notifyListeners();

    await _apiWorkout.executeToggleExercise(token, idExercise);
  }

  Future<Map<String, dynamic>> completeActiveSession(String token) async {
    if (_activeSession == null)
      return {'success': false, 'message': 'No active session found.'};

    final result = await _apiWorkout.executeCompleteSession(
      token,
      _activeSession!['id_session'],
    );

    if (result['success'] == true) {
      _activeSession = {..._activeSession!, 'status': 'completed'};
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> skipActiveSession(String token) async {
    if (_activeSession == null)
      return {'success': false, 'message': 'No active session found.'};

    final result = await _apiWorkout.executeSkipSession(
      token,
      _activeSession!['id_session'],
    );

    if (result['success'] == true) {
      _activeSession = {..._activeSession!, 'status': 'skipped'};
      _hasFetched = false;
      notifyListeners();
    }
    return result;
  }

  void clearState() {
    _activeSession = null;
    _adaptations = [];
    _isLoading = false;
    _hasFetched = false;
    _loadedToken = null;
    notifyListeners();
  }
}
