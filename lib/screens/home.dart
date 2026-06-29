import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../auth/workout_provider.dart';
import '../auth/history_provider.dart';
import '../auth/calorie_provider.dart'; // 🔥 TAMBAHAN: Import Calorie Provider

class HomeScreen extends StatelessWidget {
  final Function(int) onTabSwitch;

  const HomeScreen({super.key, required this.onTabSwitch});

  static const _cardWorkoutBg = Color(0xFF29523B);
  static const _cardWorkoutCompletedBg = Color(0xFF193325);
  static const _cardWorkoutSkippedBg = Color(0xFF944A34);
  static const _textDark = Color(0xFF1A2E22);
  static const _coralOrange = Color(0xFFE57C5D);
  static const _metricBlue = Color(0xFF5A92AF);
  static const _metricGold = Color(0xFFD4A359);
  static const _accentActiveGreen = Color(0xFF2E6644);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context);
    final calorieProvider = Provider.of<CalorieProvider>(
      context,
    ); // 🔥 TAMBAHAN: Baca state kalori harian

    final profile = authProvider.profileData;
    final overview = historyProvider.overviewData;
    final activeSession = workoutProvider.activeSession;
    final List<dynamic> moodLogs =
        historyProvider.detailsData?['mood_history'] ?? [];

    final String displayName = profile?['name'] ?? 'User';

    return Column(
      children: [
        _buildTopHeader(displayName),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                _buildMoodCheckInCard(moodLogs),
                const SizedBox(height: 16),
                // 🔥 MODIFIKASI: Menyuntikkan data kalori hari ini ke dalam fungsi builder kartu
                _buildCalorieTrackerCard(
                  overview,
                  calorieProvider.totalConsumed,
                ),
                const SizedBox(height: 16),
                _buildWorkoutCard(activeSession),
                const SizedBox(height: 16),
                _buildQuickMetricsGrid(profile, overview),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader(String name) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E4030), Color(0xFF2D5A40)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => onTabSwitch(5),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCheckInCard(List<dynamic> moodLogs) {
    final emojis = ['😔', '😟', '😐', '🙂', '🤩'];
    bool lowMoodLoggedToday = moodLogs.isNotEmpty;
    Map<String, dynamic>? latestMood;
    if (lowMoodLoggedToday) {
      latestMood = moodLogs.first;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => onTabSwitch(1),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F2EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    color: Color(0xFF1E4030),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mood Check-In',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!lowMoodLoggedToday) ...[
            Text(
              'You haven\'t recorded your status today.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => onTabSwitch(1),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  'Log Your Mood Today',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentActiveGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(emojis.length, (index) {
                int scoreValue = index + 1;
                bool isSelected = latestMood?['skor_mood'] == scoreValue;
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F2EC)
                        : const Color(0xFFF5F7F6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? _accentActiveGreen
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: 22),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF7A8E81),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: 'Today: '),
                  TextSpan(
                    text:
                        '${latestMood?['mood'] ?? 'Neutral'} (${latestMood?['skor_mood'] ?? 3}/5)',
                    style: const TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' — Logged at ${latestMood?['log_date'] ?? 'today'}',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 🔥 MODIFIKASI: Menerima parameter todayConsumed dari CalorieProvider harian
  Widget _buildCalorieTrackerCard(
    Map<String, dynamic>? overview,
    int todayConsumed,
  ) {
    int consumed =
        todayConsumed; // 😉 SINKRON: Menggunakan total kalori hari ini murni
    int goal =
        int.tryParse(overview?['daily_target_calorie'].toString() ?? '2100') ??
        2100; // Default disamakan ke 2100 agar sejalan dengan CalorieTrackerScreen

    double progressRatio = (consumed / goal).clamp(0.0, 1.0);
    int percentage = (progressRatio * 100).toInt();
    int remaining = (goal - consumed) < 0 ? 0 : (goal - consumed);

    return InkWell(
      onTap: () => onTabSwitch(2),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDF0ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: _coralOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Calorie Tracker',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$consumed',
                  style: const TextStyle(
                    color: _coralOrange,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'serif',
                  ),
                ),
                Text(
                  ' / $goal kcal',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: _coralOrange,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressRatio,
                minHeight: 8,
                backgroundColor: const Color(0xFFEAEFEA),
                valueColor: const AlwaysStoppedAnimation<Color>(_coralOrange),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              remaining == 0
                  ? 'Daily caloric goal reached!'
                  : '$remaining kcal remaining today',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic>? activeSession) {
    bool hasWorkout = activeSession != null;
    String status = hasWorkout
        ? (activeSession['status'] ?? 'pending').toString().toLowerCase()
        : '';

    Color currentCardBg = const Color(0xFFEFF3F0);
    if (hasWorkout) {
      if (status == 'completed') {
        currentCardBg = _cardWorkoutCompletedBg;
      } else if (status == 'skipped') {
        currentCardBg = _cardWorkoutSkippedBg;
      } else {
        currentCardBg = _cardWorkoutBg;
      }
    }

    List<String> tags = [];
    if (hasWorkout && activeSession['exercises'] != null) {
      final exercises = activeSession['exercises'] as List;
      tags = exercises.take(3).map((e) => e['title'].toString()).toList();
    }

    return InkWell(
      onTap: () => onTabSwitch(3),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: currentCardBg,
          borderRadius: BorderRadius.circular(24),
          border: hasWorkout ? null : Border.all(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasWorkout
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: hasWorkout ? Colors.white : _cardWorkoutBg,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Today's Workout",
                  style: TextStyle(
                    color: hasWorkout ? Colors.white : _textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: hasWorkout ? Colors.white70 : Colors.grey[500],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!hasWorkout) ...[
              const Text(
                'No dynamic workout session generated for today yet.',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => onTabSwitch(3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cardWorkoutBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Get AI Recommendation Routine',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Status: ${status.toUpperCase()}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activeSession['session_name'] ?? 'Daily Routine Split',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status == 'skipped'
                    ? 'This session was postponed. Content will roll over to tomorrow.'
                    : 'Based on your content-filtering preferences & profile matrix',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMetricsGrid(
    Map<String, dynamic>? profile,
    Map<String, dynamic>? overview,
  ) {
    String streakVal = "${overview?['workouts_completed'] ?? '0'}";
    String currentWeight = "${profile?['weight'] ?? '-'}";

    return Row(
      children: [
        Expanded(
          child: _buildMiniMetricCard(
            Icons.local_fire_department_rounded,
            streakVal,
            'completed',
            _coralOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniMetricCard(
            Icons.scale_rounded,
            currentWeight,
            'kg weight',
            _metricGold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniMetricCard(
            Icons.local_drink_rounded,
            '8',
            'glasses water',
            _metricBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMetricCard(
    IconData icon,
    String value,
    String unit,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _textDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'serif',
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
