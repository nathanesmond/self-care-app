// ignore: file_names
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'package:self_care_app/auth/calorie_provider.dart';
import 'package:self_care_app/entity/calorie_log_item.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  static const _textDark = Color(0xFF1A2E22);
  static const _coralOrange = Color(0xFFE57C5D);
  static const _coralLightBg = Color(0xFFFDF0ED);
  static const _remainingBlue = Color(0xFF5A92AF);
  static const _fieldBg = Color(0xFFEFF5F0);

  final String _todayDate = DateTime.now().toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token =
          Provider.of<AuthProvider>(context, listen: false).token ?? '';
      Provider.of<CalorieProvider>(
        context,
        listen: false,
      ).fetchDailyCalories(token, _todayDate);
    });
  }

  void _showLogFoodModal(BuildContext context, String currentSelectedDate) {
    final foodNameController = TextEditingController();
    final calorieController = TextEditingController();
    String selectedMealType = 'Breakfast';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (stateContext, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(stateContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Log New Meal',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: foodNameController,
                    decoration: InputDecoration(
                      hintText: 'Food/Meal Name (e.g. Oats with banana)',
                      filled: true,
                      fillColor: _fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: calorieController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Calories (kcal)',
                      filled: true,
                      fillColor: _fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Meal Category',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((
                      type,
                    ) {
                      bool isSelected = selectedMealType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: _coralOrange,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : _textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedMealType = type);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E6644),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final name = foodNameController.text.trim();
                        final calStr = calorieController.text.trim();
                        if (name.isEmpty || calStr.isEmpty) return;

                        final token =
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).token ??
                            '';
                        final timeStr = TimeOfDay.now().format(stateContext);

                        // ignore: unused_local_variable
                        final result =
                            await Provider.of<CalorieProvider>(
                              context,
                              listen: false,
                            ).storeCalorieLog(
                              token: token,
                              name: name,
                              calories: int.parse(calStr),
                              mealType: selectedMealType,
                              time: timeStr,
                              date: currentSelectedDate,
                            );

                        if (modalContext.mounted) {
                          Navigator.pop(modalContext);
                        }
                      },
                      child: const Text(
                        'Save Food Log',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calorieProvider = Provider.of<CalorieProvider>(context);
    int remainingCalories =
        (calorieProvider.targetCalorie - calorieProvider.totalConsumed).clamp(
          0,
          calorieProvider.targetCalorie, // Gunakan batas atas dinamis
        );

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: calorieProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E6644),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      _buildSummaryCard(
                        calorieProvider.totalConsumed,
                        remainingCalories,
                        calorieProvider.targetCalorie,
                        calorieProvider.dailyLogs,
                      ),
                      const SizedBox(height: 16),

                      _buildLogFoodActionCard(),
                      const SizedBox(height: 24),

                      _buildMealSectionGroup(
                        'Breakfast',
                        calorieProvider.dailyLogs,
                      ),
                      const SizedBox(height: 20),
                      _buildMealSectionGroup(
                        'Lunch',
                        calorieProvider.dailyLogs,
                      ),
                      const SizedBox(height: 20),
                      _buildMealSectionGroup(
                        'Dinner',
                        calorieProvider.dailyLogs,
                      ),
                      const SizedBox(height: 20),
                      _buildMealSectionGroup(
                        'Snack',
                        calorieProvider.dailyLogs,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC85A32), Color(0xFFE57C5D)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: const Text(
        'Calorie Tracker',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          fontFamily: 'serif',
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    int consumed,
    int remaining,
    int targetGoal, // Tambahkan parameter ini
    List<CalorieLogItem> logs,
  ) {
    int breakfastKcal = logs
        .where((m) => m.mealType == 'Breakfast')
        .fold(0, (sum, m) => sum + m.jumlahCalori);
    int lunchKcal = logs
        .where((m) => m.mealType == 'Lunch')
        .fold(0, (sum, m) => sum + m.jumlahCalori);
    int dinnerKcal = logs
        .where((m) => m.mealType == 'Dinner')
        .fold(0, (sum, m) => sum + m.jumlahCalori);
    int snackKcal = logs
        .where((m) => m.mealType == 'Snack')
        .fold(0, (sum, m) => sum + m.jumlahCalori);

    double total = consumed == 0 ? 1.0 : consumed.toDouble();
    double pBreakfast = breakfastKcal / total;
    double pLunch = lunchKcal / total;
    double pDinner = dinnerKcal / total;
    double pSnack = snackKcal / total;

    const cBreakfast = Color(0xFF2E6644);
    const cLunch = Color(0xFFE57C5D);
    const cDinner = Color(0xFFD4A359);
    const cSnack = Color(0xFF5A92AF);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CustomPaint(
                      painter: MealTypeRingPainter(
                        breakfastP: pBreakfast,
                        lunchP: pLunch,
                        dinnerP: pDinner,
                        snackP: pSnack,
                        hasData: consumed > 0,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$consumed',
                        style: const TextStyle(
                          color: _coralOrange,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'serif',
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'kcal',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildMetricRow('Goal', '$targetGoal kcal', isBold: false),
                    const SizedBox(height: 8),
                    _buildMetricRow(
                      'Remaining',
                      '$remaining kcal',
                      isBold: true,
                      valueColor: _remainingBlue,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFFEFF3F1), thickness: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniLabel('B', '$breakfastKcal', cBreakfast),
                        _buildMiniLabel('L', '$lunchKcal', cLunch),
                        _buildMiniLabel('D', '$dinnerKcal', cDinner),
                        _buildMiniLabel('S', '$snackKcal', cSnack),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: targetGoal == 0
                  ? 0.0
                  : (consumed / targetGoal).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: const Color(0xFFEFF5F1),
              valueColor: const AlwaysStoppedAnimation<Color>(_coralOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String val, {
    required bool isBold,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            color: valueColor ?? _textDark,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniLabel(String letter, String kcal, Color indicatorColor) {
    return Row(
      children: [
        Text(
          letter,
          style: TextStyle(
            color: indicatorColor,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          kcal,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLogFoodActionCard() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => _showLogFoodModal(context, _todayDate),
        style: ElevatedButton.styleFrom(
          backgroundColor: _coralLightBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: _coralOrange, size: 20),
            SizedBox(width: 6),
            Text(
              'Log Food / Meal',
              style: TextStyle(
                color: _coralOrange,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSectionGroup(
    String sectionTitle,
    List<CalorieLogItem> allLogs,
  ) {
    final filteredMeals = allLogs
        .where((meal) => meal.mealType == sectionTitle)
        .toList();
    final int totalKcal = filteredMeals.fold(
      0,
      (sum, meal) => sum + meal.jumlahCalori,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sectionTitle,
              style: const TextStyle(
                color: _textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (filteredMeals.isNotEmpty)
              Text(
                '$totalKcal kcal',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: filteredMeals.isEmpty
              ? ListTile(
                  title: Text(
                    'Nothing logged yet',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  trailing: TextButton(
                    onPressed: () => _showLogFoodModal(context, _todayDate),
                    child: const Text(
                      '+ Add',
                      style: TextStyle(
                        color: _coralOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredMeals.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Color(0xFFEFF3F1), height: 1),
                  itemBuilder: (context, index) {
                    final meal = filteredMeals[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: _coralLightBg,
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: _coralOrange,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        meal.namaMakanan,
                        style: const TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        meal.loggedTime,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${meal.jumlahCalori} kcal',
                            style: const TextStyle(
                              color: _coralOrange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Transform.translate(
                            offset: const Offset(8, 0),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () async {
                                final token =
                                    Provider.of<AuthProvider>(
                                      context,
                                      listen: false,
                                    ).token ??
                                    '';
                                final result =
                                    await Provider.of<CalorieProvider>(
                                      context,
                                      listen: false,
                                    ).deleteCalorieLog(
                                      token,
                                      meal.idCalorieLog,
                                      _todayDate,
                                    );

                                if (result['success'] == true &&
                                    context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Catatan makanan berhasil dihapus',
                                      ),
                                    ),
                                  );
                                }
                              },
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              splashRadius: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class MealTypeRingPainter extends CustomPainter {
  final double breakfastP;
  final double lunchP;
  final double dinnerP;
  final double snackP;
  final bool hasData;

  MealTypeRingPainter({
    required this.breakfastP,
    required this.lunchP,
    required this.dinnerP,
    required this.snackP,
    required this.hasData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 12.0;
    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width / 2) - (strokeWidth / 2),
    );

    if (!hasData) {
      Paint placeholderPaint = Paint()
        ..color = const Color(0xFFEFF5F1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, 0, 2 * pi, false, placeholderPaint);
      return;
    }

    Paint pBreakfast = Paint()
      ..color = const Color(0xFF2E6644)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    Paint pLunch = Paint()
      ..color = const Color(0xFFE57C5D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    Paint pDinner = Paint()
      ..color = const Color(0xFFD4A359)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    Paint pSnack = Paint()
      ..color = const Color(0xFF5A92AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double startAngle = -pi / 2;

    if (breakfastP > 0) {
      double sweep = breakfastP * 2 * pi;
      canvas.drawArc(rect, startAngle, sweep, false, pBreakfast);
      startAngle += sweep;
    }
    if (lunchP > 0) {
      double sweep = lunchP * 2 * pi;
      canvas.drawArc(rect, startAngle, sweep, false, pLunch);
      startAngle += sweep;
    }
    if (dinnerP > 0) {
      double sweep = dinnerP * 2 * pi;
      canvas.drawArc(rect, startAngle, sweep, false, pDinner);
      startAngle += sweep;
    }
    if (snackP > 0) {
      double sweep = snackP * 2 * pi;
      canvas.drawArc(rect, startAngle, sweep, false, pSnack);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
