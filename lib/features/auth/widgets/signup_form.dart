import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onLoginTap;

  const SignupForm({super.key, required this.onLoginTap});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isOtpSent = false;
  bool _canGetOtp = false;

  Timer? _timer;
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _canGetOtp = _phoneController.text.length == 10;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isOtpSent = true;
      _resendSeconds = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendSeconds--;
        });
      }
    });
  }

  void _register() async {
    // setState(() => _isLoading = true);
    // await ref.read(authProvider.notifier).register({
    //   'firstName': _firstNameController.text.trim(),
    //   'lastName': _lastNameController.text.trim(),
    //   'email': _emailController.text.trim(),
    //   'password': _passwordController.text.trim(),
    //   'role': 'user', // Default to typical user
    // });
    // setState(() => _isLoading = false);

    // final error = ref.read(authProvider).error;
    // if (error != null && mounted) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(error)));
    // }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please fill in your details to continue',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),

        // First Name & Last Name Row
        Row(
          children: [
            Expanded(child: _buildInputField(hint: 'First Name')),
            const SizedBox(width: 16),
            Expanded(child: _buildInputField(hint: 'Last Name')),
          ],
        ),
        const SizedBox(height: 16),

        // Email Address
        _buildInputField(
          hint: 'Email Address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Phone Number with Get OTP
        _buildInputField(
          controller: _phoneController,
          hint: 'Phone Number',
          keyboardType: TextInputType.phone,
          maxLength: 10,
          suffix: TextButton(
            onPressed: _canGetOtp ? _startTimer : null,
            child: Text(
              'Get OTP',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _canGetOtp
                    ? const Color(0xFF3B82F6)
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: _canGetOtp ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),

        if (_isOtpSent) ...[
          const SizedBox(height: 16),
          _buildInputField(
            controller: _otpController,
            hint: 'Enter OTP',
            keyboardType: TextInputType.number,
            maxLength: 6,
            suffix: TextButton(
              onPressed: () {},
              child: Text(
                'Verify',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _resendSeconds > 0
                  ? 'Resend OTP in ${_resendSeconds}s'
                  : 'Resend OTP',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ).animate().fadeIn(),
        ],

        const SizedBox(height: 16),

        // Password
        _buildInputField(
          hint: 'Password',
          isPassword: true,
          obscureText: !_isPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        const SizedBox(height: 16),

        // Terms and Conditions Checked
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _agreeToTerms = !_agreeToTerms;
                });
              },
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: _agreeToTerms
                      ? const Color(0xFF3B82F6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _agreeToTerms
                        ? const Color(0xFF3B82F6)
                        : colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: _agreeToTerms
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'I agree to the ',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Terms and Conditions',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF3B82F6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Register & Login Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF9333EA), Color(0xFFDB2777)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Register & Login',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: colorScheme.outline)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR CONTINUE WITH',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Divider(color: colorScheme.outline)),
          ],
        ),

        const SizedBox(height: 24),

        // Google Sign In
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              LucideIcons.chrome,
              size: 20,
              color: Color(0xFFD94839),
            ),
            label: Text(
              'Sign in with Google',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Login Link
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: widget.onLoginTap,
                child: Text(
                  'Sign in',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: bottomInset > 0 ? 20 : 0),
      ],
    );
  }

  Widget _buildInputField({
    TextEditingController? controller,
    required String hint,
    Widget? suffix,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: GoogleFonts.inter(color: colorScheme.onSurface),
      inputFormatters: maxLength != null
          ? [LengthLimitingTextInputFormatter(maxLength)]
          : null,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        counterText: "", // Hide character counter
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: onToggleVisibility,
              )
            : suffix,
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
