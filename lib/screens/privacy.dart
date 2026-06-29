import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  static const _primaryGreen = Color(0xFF1E4030);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _primaryGreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: _primaryGreen,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Privacy & Data',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your trust is our top priority. We believe that your health data is deeply personal, which is why we built this app with a privacy-first approach.\n\n'
              '• We do not sell your personal data to third parties.\n'
              '• Your fitness tracking and mood logs are strictly used to generate insights just for you.\n'
              '• We use industry-standard encryption to protect your passwords and data.\n\n'
              'If you have any concerns regarding your data, you can request account deletion at any time.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
