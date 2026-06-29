import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'package:self_care_app/auth/mood_provider.dart';
import 'package:self_care_app/auth/calorie_provider.dart';
import 'package:self_care_app/auth/workout_provider.dart';
import 'package:self_care_app/auth/history_provider.dart';
import 'package:self_care_app/auth/admin_provider.dart';

import 'screens/login.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => CalorieProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const WellnessApp(),
    ),
  );
}

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SF Pro Display', useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}
