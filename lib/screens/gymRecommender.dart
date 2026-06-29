import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../auth/workout_provider.dart';

class GymRecommenderScreen extends StatefulWidget {
  const GymRecommenderScreen({super.key});

  @override
  State<GymRecommenderScreen> createState() => _GymRecommenderScreenState();
}

class _GymRecommenderScreenState extends State<GymRecommenderScreen> {
  static const _textDark = Color(0xFF1A2E22);
  static const _headerGreen = Color(0xFF1E4030);
  static const _midGreen = Color(0xFF2D5A40);
  static const _buttonActiveGreen = Color(0xFF2E6644);
  static const _labelGrey = Color(0xFF7A8E81);
  static const _orangeMetric = Color(0xFFD4A359);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token =
          Provider.of<AuthProvider>(context, listen: false).token ?? '';
      Provider.of<WorkoutProvider>(
        context,
        listen: false,
      ).initializeForUser(token);
    });
  }

  void _generateRoutineManual() {
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';

    Provider.of<WorkoutProvider>(
      context,
      listen: false,
    ).generateTodayWorkout(token);
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Column(
      children: [
        _buildGradientHeader(workoutProvider),
        Expanded(
          child: workoutProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _buttonActiveGreen,
                    ),
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: workoutProvider.activeSession == null
                      ? _buildInitialStateView()
                      : _buildRecommendationListView(workoutProvider),
                ),
        ),
      ],
    );
  }

  Widget _buildGradientHeader(WorkoutProvider provider) {
    String sessionName = "CBF Recommender";
    if (provider.activeSession != null) {
      sessionName = provider.activeSession!['session_name'] ?? 'Daily Workout';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_headerGreen, _midGreen],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODAY\'S ADAPTIVE PLAN (CBF ENGINE)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sessionName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialStateView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bolt_rounded,
              size: 64,
              color: _buttonActiveGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Ready for today\'s tailored session?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _generateRoutineManual,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonActiveGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Generate Today\'s Routine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationListView(WorkoutProvider provider) {
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';
    final session = provider.activeSession!;
    final List<dynamic> exercises = session['exercises'] ?? [];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.adaptations.isNotEmpty)
                  ...provider.adaptations.map(
                    (msg) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              msg,
                              style: const TextStyle(
                                color: Color(0xFF664D03),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TARGET EXERCISES (${exercises.length})',
                      style: const TextStyle(
                        color: _labelGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Status: ${session['status'].toString().toUpperCase()}',
                      style: const TextStyle(
                        color: _orangeMetric,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFFEFF3F1), thickness: 1),
                ),

                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exercises.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    bool isDone = ex['is_done'] == 1;

                    return GestureDetector(
                      onTap: session['status'] == 'pending'
                          ? () => provider.toggleExerciseCheckLocal(
                              token,
                              ex['id_session_exercise'],
                              index,
                            )
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7F6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDone
                                ? _buttonActiveGreen.withOpacity(0.4)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? _buttonActiveGreen
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDone
                                      ? _buttonActiveGreen
                                      : const Color(0xFFD2DAD5),
                                  width: 1.5,
                                ),
                              ),
                              child: isDone
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex['title'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: _textDark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tool: ${ex['equipment']} | Target: ${ex['body_part']}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              ex['level'].toString().toUpperCase(),
                              style: const TextStyle(
                                color: _orangeMetric,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                if (session['status'] == 'pending')
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () async {
                              final res = await provider.skipActiveSession(
                                token,
                              );
                              if (res['success'] == true && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sesi ditunda dan digeser ke besok hari.',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFC85A32),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFFC85A32),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              final res = await provider.completeActiveSession(
                                token,
                              );
                              if (res['success'] == true && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '🎉 Selamat! Sesi latihan hari ini selesai.',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _buttonActiveGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Complete Workout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _buttonActiveGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          session['status'] == 'completed'
                              ? Icons.check_circle_rounded
                              : Icons.pause_circle_filled_rounded,
                          color: _buttonActiveGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            session['status'] == 'completed'
                                ? 'TODAY\'S SESSION COMPLETED!'
                                : 'TODAY\'S SESSION SKIPPED (PASSED TO TOMORROW)',
                            style: const TextStyle(
                              color: _buttonActiveGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
