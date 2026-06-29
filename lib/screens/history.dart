import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'package:self_care_app/auth/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _activeSubTab = 0;

  static const _textDark = Color(0xFF1A2E22);
  static const _headerGreen = Color(0xFF1E4030);
  static const _midGreen = Color(0xFF2D5A40);
  static const _accentActiveGreen = Color(0xFF2E6644);
  static const _coralOrange = Color(0xFFE57C5D);
  static const _metricBlue = Color(0xFF5A92AF);
  static const _metricGold = Color(0xFFD4A359);
  static const _cardBg = Colors.white;
  static const _labelGrey = Color(0xFF8A9E92);

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (historyProvider.overviewData == null && !historyProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final token = authProvider.token ?? '';
        print(
          "👉 [DEBUG HISTORY] Fetching history logs. Token status: ${token.isNotEmpty}",
        );
        historyProvider.fetchHistoryData(token);
      });
    }

    return Column(
      children: [
        _buildGradientHeaderWithTabs(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildSelectedTabContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientHeaderWithTabs() {
    final subTabs = ['Overview', 'Mood', 'Calories', 'Workouts'];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_headerGreen, _midGreen],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR JOURNEY',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'serif',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              color: const Color(0xFFF1F5F2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(subTabs.length, (index) {
                    bool isActive = _activeSubTab == index;
                    return GestureDetector(
                      onTap: () => setState(() => _activeSubTab = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? _accentActiveGreen : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          subTabs[index],
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : _textDark.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_activeSubTab) {
      case 0:
        return _buildOverviewLayout();
      case 1:
        return _buildMoodLayout();
      case 2:
        return _buildCaloriesLayout();
      case 3:
        return _buildWorkoutsLayout();
      default:
        return _buildOverviewLayout();
    }
  }

  Widget _buildOverviewLayout() {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final overview = historyProvider.overviewData;
    final details = historyProvider.detailsData;

    final String avgMood = "${overview?['average_mood'] ?? '0.0'}/5";
    final String totalCalories = "${overview?['total_calories'] ?? '0'}";
    final String totalWorkouts = "${overview?['workouts_completed'] ?? '0'}";

    final List<dynamic> rawCalorieHistory = details?['calorie_history'] ?? [];
    final List<dynamic> rawMoodHistory = details?['mood_history'] ?? [];
    final int targetCalorieGoal = overview?['daily_target_calorie'] ?? 2000;

    final List<double> recentMoodScores = rawMoodHistory
        .take(7)
        .map((log) {
          return double.tryParse(log['skor_mood'].toString()) ?? 3.0;
        })
        .toList()
        .reversed
        .toList();

    DateTime now = DateTime.now();
    DateTime mondayOfThisWeek = now.subtract(Duration(days: now.weekday - 1));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      key: const ValueKey('OverviewKey'),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMiniSummaryCard(
                  '🤩',
                  avgMood,
                  'Avg Mood',
                  _metricBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniSummaryCard(
                  '🔥',
                  totalCalories,
                  'Total Kcal',
                  _coralOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniSummaryCard(
                  '💪',
                  totalWorkouts,
                  'Workouts',
                  _metricGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildBaseHistoryContainer(
            title: 'Mood Trend (${overview?['mood_trend'] ?? 'Stabil'})',
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: recentMoodScores.isEmpty
                  ? const Center(
                      child: Text('Not enough data to calculate trend lines.'),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            size: const Size(double.infinity, double.infinity),
                            painter: DynamicMoodLinePainter(
                              scores: recentMoodScores,
                              lineColor: _accentActiveGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '7 days ago',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Today',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          _buildBaseHistoryContainer(
            title: 'Calorie Intake (This Week)',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final daysLabels = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ];

                    DateTime targetDay = mondayOfThisWeek.add(
                      Duration(days: index),
                    );
                    String targetDayStr = targetDay.toIso8601String().split(
                      'T',
                    )[0];

                    int dailySum = 0;
                    for (var log in rawCalorieHistory) {
                      if (log['log_date'] == targetDayStr) {
                        dailySum +=
                            int.tryParse(log['jumlah_kalori'].toString()) ?? 0;
                      }
                    }

                    return _buildOverviewBarGroup(
                      dailySum,
                      targetCalorieGoal,
                      showLabel: true,
                      dayLabel: daysLabels[index],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummaryCard(
    String icon,
    String val,
    String desc,
    Color valColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            val,
            style: TextStyle(
              color: valColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewBarGroup(
    int consumed,
    int goal, {
    bool showLabel = false,
    String dayLabel = '',
  }) {
    double ratio = goal > 0 ? (consumed / goal).clamp(0.0, 1.2) : 0.0;
    const double maxGraphHeight = 80.0;
    double filledHeight = maxGraphHeight * (ratio > 1.0 ? 1.0 : ratio);

    return Column(
      children: [
        Text(
          consumed > 0 ? '$consumed' : '-',
          style: TextStyle(
            color: ratio > 1.0 ? Colors.red[400] : _textDark,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 16,
              height: maxGraphHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5F1),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: 16,
              height: filledHeight == 0 ? 2 : filledHeight,
              decoration: BoxDecoration(
                color: ratio > 1.0 ? const Color(0xFFD4A359) : _coralOrange,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          Text(
            dayLabel,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoodLayout() {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final List<dynamic> moodLogs =
        historyProvider.detailsData?['mood_history'] ?? [];

    final List<double> chartScores = moodLogs
        .take(10)
        .map((log) {
          return double.tryParse(log['skor_mood'].toString()) ?? 3.0;
        })
        .toList()
        .reversed
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      key: const ValueKey('MoodKey'),
      child: Column(
        children: [
          _buildBaseHistoryContainer(
            title: 'Mood Fluctuations (Latest Logs)',
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: chartScores.isEmpty
                  ? const Center(child: Text("No tracking records logged yet."))
                  : Column(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            size: const Size(double.infinity, double.infinity),
                            painter: DynamicMoodLinePainter(
                              scores: chartScores,
                              lineColor: _accentActiveGreen,
                              showGridLines: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Earlier',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Latest',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          moodLogs.isEmpty
              ? _buildBaseHistoryContainer(
                  title: "No Log",
                  child: const Center(
                    child: Text("Belum ada riwayat catatan mood."),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: moodLogs.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Color(0xFFEFF3F1), height: 1),
                    itemBuilder: (context, index) {
                      final log = moodLogs[index];
                      final String dateString = log['log_date'] ?? '-';
                      final int score = log['skor_mood'] ?? 3;

                      String moodEmoji = '😐';
                      if (score >= 4) moodEmoji = '🤩';
                      if (score <= 2) moodEmoji = '😟';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateString,
                                    style: const TextStyle(
                                      color: _textDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    log['notes'] ?? 'No notes.',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  moodEmoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "$score/5",
                                  style: const TextStyle(
                                    color: _textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCaloriesLayout() {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final List<dynamic> calorieLogs =
        historyProvider.detailsData?['calorie_history'] ?? [];
    final int targetCalorie =
        historyProvider.overviewData?['daily_target_calorie'] ?? 2000;

    DateTime now = DateTime.now();
    DateTime mondayOfThisWeek = now.subtract(Duration(days: now.weekday - 1));

    Map<String, List<dynamic>> groupedCalorieLogs = {};
    for (var log in calorieLogs) {
      String dateKey = log['log_date'] ?? 'Unknown Date';
      groupedCalorieLogs.putIfAbsent(dateKey, () => []).add(log);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      key: const ValueKey('CalorieKey'),
      child: Column(
        children: [
          _buildBaseHistoryContainer(
            title: 'Weekly Calories vs Goal',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final days = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ];

                    DateTime targetDay = mondayOfThisWeek.add(
                      Duration(days: index),
                    );
                    String targetDayStr = targetDay.toIso8601String().split(
                      'T',
                    )[0];

                    int consumedVal = 0;
                    for (var log in calorieLogs) {
                      if (log['log_date'] == targetDayStr) {
                        consumedVal +=
                            int.tryParse(log['jumlah_kalori'].toString()) ?? 0;
                      }
                    }

                    double ratio = targetCalorie > 0
                        ? (consumedVal / targetCalorie).clamp(0.0, 1.2)
                        : 0.0;
                    const double maxGraphHeight = 80.0;
                    double filledHeight =
                        maxGraphHeight * (ratio > 1.0 ? 1.0 : ratio);

                    return Column(
                      children: [
                        Text(
                          consumedVal > 0 ? '$consumedVal' : '-',
                          style: TextStyle(
                            color: ratio > 1.0 ? Colors.red[400] : _textDark,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 24,
                              height: maxGraphHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF5F1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: filledHeight == 0 ? 2 : filledHeight,
                              decoration: BoxDecoration(
                                color: ratio > 1.0
                                    ? const Color(0xFFD4A359)
                                    : _coralOrange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          days[index],
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFEFF3F1)),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 5,
                          backgroundColor: _coralOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Consumed kcal',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '•   Target: $targetCalorie kcal/day',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          groupedCalorieLogs.isEmpty
              ? _buildBaseHistoryContainer(
                  title: "No Food Log",
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Belum ada log makanan masuk harian."),
                    ),
                  ),
                )
              : Column(
                  children: groupedCalorieLogs.keys.map((dateString) {
                    final dayMeals = groupedCalorieLogs[dateString]!;

                    int dayTotalCalories = dayMeals.fold(
                      0,
                      (sum, item) =>
                          sum +
                          (int.tryParse(item['jumlah_kalori'].toString()) ?? 0),
                    );
                    bool isDeficit = dayTotalCalories <= targetCalorie;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      color: _headerGreen,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      dateString, // Contoh: 2026-06-22
                                      style: const TextStyle(
                                        color: _textDark,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDeficit
                                        ? const Color(0xFFE8F2EC)
                                        : const Color(0xFFFDF0ED),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "$dayTotalCalories kcal",
                                    style: TextStyle(
                                      color: isDeficit
                                          ? _accentActiveGreen
                                          : _coralOrange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xFFEFF3F1), height: 1),

                          ...List.generate(dayMeals.length, (index) {
                            final log = dayMeals[index];
                            int kcal =
                                int.tryParse(log['jumlah_kalori'].toString()) ??
                                0;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: index == dayMeals.length - 1
                                    ? null
                                    : const Border(
                                        bottom: BorderSide(
                                          color: Color(0xFFEFF3F1),
                                          width: 1,
                                        ),
                                      ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log['nama_makanan'] ?? 'Makanan',
                                          style: const TextStyle(
                                            color: _textDark,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${log['meal_type'] ?? 'Snack'}  •  ${log['logged_time'] ?? '00:00'}",
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "$kcal kcal",
                                    style: const TextStyle(
                                      color: _coralOrange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsLayout() {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final List<dynamic> workoutLogs =
        historyProvider.detailsData?['workout_history'] ?? [];

    if (workoutLogs.isEmpty) {
      return _buildBaseHistoryContainer(
        title: "No Session History",
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text("Belum ada sesi latihan yang diselesaikan."),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      key: const ValueKey('WorkoutKey'),
      itemCount: workoutLogs.length,
      itemBuilder: (context, index) {
        final wk = workoutLogs[index];
        bool isCompleted = wk['status'] == 'completed';

        Color badgeColor = isCompleted
            ? const Color(0xFFE8F2EC)
            : const Color(0xFFFDF0ED);
        Color txtColor = isCompleted ? _accentActiveGreen : _coralOrange;
        String burnedKcal = isCompleted ? "320 kcal" : "0 kcal";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    wk['session_name'] ?? 'Workout Sesi',
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCompleted ? "COMPLETED" : "SKIPPED",
                      style: TextStyle(
                        color: txtColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                wk['log_date'] ?? '-',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: _labelGrey,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '45 min',
                    style: TextStyle(
                      color: _labelGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: _labelGrey,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    burnedKcal,
                    style: const TextStyle(
                      color: _labelGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBaseHistoryContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class DynamicMoodLinePainter extends CustomPainter {
  final List<double> scores;
  final Color lineColor;
  final bool showGridLines;

  DynamicMoodLinePainter({
    required this.scores,
    required this.lineColor,
    this.showGridLines = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final double verticalPadding = size.height * 0.15;
    final double graphHeight = size.height - (2 * verticalPadding);
    final double stepX = scores.length > 1
        ? size.width / (scores.length - 1)
        : size.width;

    double getY(double score) {
      double clamped = score.clamp(1.0, 5.0);
      double percentage = (clamped - 1.0) / 4.0;
      return size.height - verticalPadding - (percentage * graphHeight);
    }

    if (showGridLines) {
      Paint gridPaint = Paint()
        ..color = Colors.grey[200]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      for (double level in [1.0, 3.0, 5.0]) {
        double yPos = getY(level);
        canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), gridPaint);
      }
    }

    List<Offset> coordinates = [];
    for (int i = 0; i < scores.length; i++) {
      coordinates.add(Offset(i * stepX, getY(scores[i])));
    }

    Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    Path path = Path()..moveTo(coordinates[0].dx, coordinates[0].dy);

    for (int i = 0; i < coordinates.length - 1; i++) {
      var controlPointX = (coordinates[i].dx + coordinates[i + 1].dx) / 2;
      var controlPointY = (coordinates[i].dy + coordinates[i + 1].dy) / 2;
      path.quadraticBezierTo(
        coordinates[i].dx,
        coordinates[i].dy,
        controlPointX,
        controlPointY,
      );
    }
    path.lineTo(coordinates.last.dx, coordinates.last.dy);
    canvas.drawPath(path, linePaint);

    Paint outerCirclePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    Paint innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var point in coordinates) {
      canvas.drawCircle(point, 5.5, outerCirclePaint);
      canvas.drawCircle(point, 2.5, innerCirclePaint);
    }
  }

  @override
  bool shouldRepaint(covariant DynamicMoodLinePainter oldDelegate) => true;
}
