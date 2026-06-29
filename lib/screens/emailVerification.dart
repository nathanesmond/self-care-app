import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'package:self_care_app/screens/onboarding.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final bool isNewUser; // 🔥 ADD THIS FLAG
  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.isNewUser,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _otpController = TextEditingController();
  static const _primaryGreen = Color(0xFF1E4030);

  void _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.verifyEmail(widget.email, otp);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email Verified!'),
            backgroundColor: Colors.green,
          ),
        );

        // 🔥 CONDITIONAL ROUTING BASED ON THE FLAG
        if (widget.isNewUser) {
          // If they are registering, go to Onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        } else {
          // If they just changed their email, refresh profile data and pop back to the Main Layout/Profile
          authProvider.fetchProfileData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  void _handleResend() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sending new code...')));
    final result = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).resendVerificationEmail(widget.email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _primaryGreen),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a 6-digit verification code to ${widget.email}.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: '6-Digit Code',
                filled: true,
                fillColor: Colors.white,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Verify Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: isLoading ? null : _handleResend,
                child: const Text(
                  'Didn\'t receive a code? Resend',
                  style: TextStyle(
                    color: _primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
