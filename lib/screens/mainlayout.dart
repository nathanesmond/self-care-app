import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'package:self_care_app/auth/workout_provider.dart';
import 'package:self_care_app/auth/history_provider.dart';
import 'package:self_care_app/auth/calorie_provider.dart'; // 🔥 TAMBAHAN IMPORT BARU

import 'home.dart';
import 'moodTracker.dart';
import 'calorieTracker.dart';
import 'gymRecommender.dart';
import 'history.dart';
import 'profile.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentNavIndex = 0;

  // Global Color Constants
  static const _headerGreen = Color(0xFF1E4030);
  static const _navActiveBg = Color(0xFFE1ECE5);
  static const _navIconUnselected = Color(0xFF7A8E81);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomeScreen(onTabSwitch: _handleTabSelection),
      const MoodTrackerScreen(),
      const CalorieTrackerScreen(),
      const GymRecommenderScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token =
          Provider.of<AuthProvider>(context, listen: false).token ?? '';
      if (token.isNotEmpty) {
        print(
          "👉 [MAINLAYOUT] Booting pertama: Menarik seluruh data dashboard Home & Sinkronisasi...",
        );

        // 🔥 1. Jalankan Sync Engine saat pertama kali aplikasi dibuka / login berhasil
        Provider.of<CalorieProvider>(
          context,
          listen: false,
        ).syncOfflineDataToServer(token);

        Provider.of<HistoryProvider>(
          context,
          listen: false,
        ).fetchHistoryData(token);
        Provider.of<WorkoutProvider>(
          context,
          listen: false,
        ).initializeForUser(token);
        Provider.of<AuthProvider>(context, listen: false).fetchProfileData();
      }
    });
  }

  void _handleTabSelection(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';

    if (index == 0) {
      print(
        "👉 [NAVBAR] User kembali ke Home. Memperbarui data Kalori, Mood, dan Workout...",
      );

      // 🔥 2. Jalankan Sync Engine setiap kali user berpindah/kembali ke halaman Home
      Provider.of<CalorieProvider>(
        context,
        listen: false,
      ).syncOfflineDataToServer(token);

      Provider.of<HistoryProvider>(
        context,
        listen: false,
      ).fetchHistoryData(token);
      Provider.of<WorkoutProvider>(
        context,
        listen: false,
      ).initializeForUser(token);
      Provider.of<AuthProvider>(context, listen: false).fetchProfileData();
    } else if (index == 3) {
      Provider.of<WorkoutProvider>(
        context,
        listen: false,
      ).initializeForUser(token);
    } else if (index == 4) {
      print("👉 [NAVBAR] Auto-refresh data riwayat diaktifkan.");
      Provider.of<HistoryProvider>(
        context,
        listen: false,
      ).fetchHistoryData(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      body: _pages[_currentNavIndex],
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildCustomBottomNavBar() {
    final navItems = [
      {'icon': Icons.home_filled, 'label': 'Home'},
      {'icon': Icons.sentiment_satisfied_alt_rounded, 'label': 'Mood'},
      {'icon': Icons.local_fire_department_rounded, 'label': 'Calories'},
      {'icon': Icons.fitness_center_rounded, 'label': 'Gym'},
      {'icon': Icons.history_rounded, 'label': 'History'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          bool isSelected = _currentNavIndex == index;
          return InkWell(
            onTap: () => _handleTabSelection(index),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _navActiveBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    navItems[index]['icon'] as IconData,
                    color: isSelected ? _headerGreen : _navIconUnselected,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  navItems[index]['label'] as String,
                  style: TextStyle(
                    color: isSelected ? _headerGreen : _navIconUnselected,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
