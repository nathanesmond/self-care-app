import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_care_app/auth/auth_provider.dart';
import 'package:self_care_app/screens/emailVerification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const _darkGreen = Color(0xFF1E4030);
  static const _midGreen = Color(0xFF2D5A40);
  static const _accentGreen = Color(0xFF3D7A56);
  static const _buttonGreen = Color(0xFF2E6644);
  static const _fieldBg = Color(0xFFEFF5F0);
  static const _labelGrey = Color(0xFF8A9E92);
  static const _textDark = Color(0xFF1A2E22);

  bool _isSubmitting = false;

  // --- VALIDATION LOGIC ---
  String? get _emailError {
    final text = _emailController.text.trim();
    if (text.isEmpty) return null; // Don't show error before they type

    // Standard email regex format checking for @ and .xxx
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(text)) return 'Please enter a valid email address';
    return null;
  }

  String? get _passwordError {
    final text = _passwordController.text;
    if (text.isEmpty) return null;
    if (text.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _handleSignUpExecution() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_emailError != null || _passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before continuing'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await authProvider.register(email, password);
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      if (mounted) {
        // 🔥 UPDATE ROUTING HERE
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EmailVerificationScreen(email: email, isNewUser: true),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Registration failed.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_darkGreen, _midGreen, _accentGreen],
            stops: [0.0, 0.4, 0.8],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: _buildHeroSection(),
                      ),
                      Expanded(child: _buildFormSheet()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'YOUR WELLNESS COMPANION',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Track. Move.\nThrive.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSheet() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(
                color: _textDark,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start your seamless health journey today',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 24),

            _buildLabel('EMAIL'),
            const SizedBox(height: 6),
            _buildEmailField(),
            const SizedBox(height: 16),

            _buildLabel('PASSWORD'),
            const SizedBox(height: 6),
            _buildPasswordField(),
            const SizedBox(height: 28),

            _buildSignUpButton(),
            const SizedBox(height: 24),

            Center(
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  children: [
                    TextSpan(
                      text: 'Sign in',
                      style: const TextStyle(
                        color: _buttonGreen,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context);
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _labelGrey,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: _textDark, fontSize: 15),
      onChanged: (_) => setState(() {}), // Triggers real-time validation
      decoration: InputDecoration(
        hintText: 'you@example.com',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        errorText: _emailError,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accentGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: _textDark, fontSize: 15),
      onChanged: (_) => setState(() {}), // Triggers real-time validation
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        errorText: _passwordError,
        errorMaxLines: 2,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accentGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _labelGrey,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accentGreen, _buttonGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _buttonGreen.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSignUpExecution,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
