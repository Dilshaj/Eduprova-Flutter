import 'dart:async';
import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:eduprova/features/auth/widgets/background_orbits.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    // Responsive sizing
    final initialSpacer = size.height * 0.32;
    final compressedSpacer = size.height * 0.10;
    final currentSpacer = isKeyboardOpen ? compressedSpacer : initialSpacer;

    return Scaffold(
      body: Stack(
        children: [
          // Background Orbits
          const Positioned.fill(child: BackgroundOrbits()),

          // Top Left Logos
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 24,
            child: Row(
              children: [
                Image.asset(
                  'assets/logos/eduprova-logo.png',
                  height: 36,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/logos/eduprova-title.png',
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ],
            ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
          ),

          // Main Content
          Column(
            children: [
              // Dynamic Spacer
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: currentSpacer,
              ),

              // Signup Card
              Expanded(
                child:
                    Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: themeExt.cardColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please fill in your details to continue',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // First Name & Last Name Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        hint: 'First Name',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInputField(
                                        hint: 'Last Name',
                                      ),
                                    ),
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
                                            : const Color(0xFF9CA3AF),
                                        fontWeight: _canGetOtp
                                            ? FontWeight.w600
                                            : FontWeight.normal,
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
                                        color: const Color(0xFF6B7280),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: _agreeToTerms
                                                ? const Color(0xFF3B82F6)
                                                : const Color(0xFFD1D5DB),
                                            width: 2,
                                          ),
                                        ),
                                        child: _agreeToTerms
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'I agree to the ',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF6B7280),
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
                                    gradient: themeExt.buyNowGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF3B82F6,
                                        ).withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {},
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
                                    const Expanded(
                                      child: Divider(color: Color(0xFFE5E7EB)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'OR CONTINUE WITH',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(color: Color(0xFFE5E7EB)),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Google Sign In
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
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
                                        color: const Color(0xFF374151),
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
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
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
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.1, duration: 600.ms),
              ),
            ],
          ),
        ],
      ),
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
    final dividerClr = Theme.of(context).dividerColor;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: maxLength != null
          ? [LengthLimitingTextInputFormatter(maxLength)]
          : null,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9CA3AF),
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3B82F6),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        counterText: "", // Hide character counter
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 20,
                  color: const Color(0xFF9CA3AF),
                ),
                onPressed: onToggleVisibility,
              )
            : suffix,
        filled: true,
        // fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerClr),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerClr),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
      ),
    );
  }
}
