import 'package:flutter/material.dart';
import 'package:self_care_app/screens/changeEmail.dart';
import 'package:self_care_app/screens/forgotPassword.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});
  static const _primaryGreen = Color(0xFF1E4030);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _primaryGreen),
        title: const Text(
          'Account Settings',
          style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildActionCard(
              context,
              Icons.email_outlined,
              'Change Email',
              'Update your login email address',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangeEmailScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              Icons.lock_outline_rounded,
              'Reset Password',
              'Send an OTP to reset your password',
              // Reusing the exact screen we built earlier!
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primaryGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2E22),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
