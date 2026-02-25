import 'package:eduprova/features/auth/providers/auth_provider.dart';
import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:eduprova/auth/widgets/background_orbits.dart';
import 'package:eduprova/auth/signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final authNotifier = ref.read(authProvider.notifier);
  bool _isLoading = false;
  String? signinType;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _isLoading = false;
      signinType = null;
    });
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      signinType = 'email';
    });
    await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    _resetState();
    final error = ref.read(authProvider).error;
    if (error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      signinType = 'google';
    });
    await authNotifier.googleSignIn();
    _resetState();
    final error = ref.read(authProvider).error;
    if (error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    // Responsive sizing
    final initialSpacer = size.height * 0.32;
    final compressedSpacer = size.height * 0.10;
    final currentSpacer = isKeyboardOpen ? compressedSpacer : initialSpacer;
    final cs = Theme.of(context).colorScheme;
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    return Scaffold(
      // backgroundColor: const Color(
      //   0xFFF0F7FF,
      // ), // Matching BackgroundOrbits theme
      body: Stack(
        children: [
          // Background Orbits
          const Positioned.fill(child: BackgroundOrbits()),

          // Top Left Logos
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
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

              // Login Card
              Expanded(
                child:
                    Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: themeExt.cardColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
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
                                  'Welcome Back',
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    // color: const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please sign in to your account',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Form Fields
                                _buildInputField(
                                  label: 'Email Address',
                                  hint: 'Enter your email',
                                  icon: LucideIcons.mail,
                                  controller: _emailController,
                                ),
                                const SizedBox(height: 20),
                                _buildInputField(
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  icon: LucideIcons.lock,
                                  isPassword: true,
                                  obscureText: !_isPasswordVisible,
                                  controller: _passwordController,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Remember Me & Forgot Password
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(
                                        () => _rememberMe = !_rememberMe,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: _rememberMe
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: _rememberMe
                                                    ? Colors.blue
                                                    : Colors.grey.shade400,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: _rememberMe
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Remember me',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Forgot Password?',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Sign In Button
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
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      'Sign In',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'OR CONTINUE WITH',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                      ),
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
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: OutlinedButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : _loginWithGoogle,
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
                                        color: const Color(0xFF1F2937),
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

                                // Signup Link
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                pageBuilder:
                                                    (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                    ) => const SignupScreen(),
                                                transitionsBuilder:
                                                    (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child,
                                                    ) => FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    ),
                                                transitionDuration:
                                                    const Duration(
                                                      milliseconds: 500,
                                                    ),
                                              ),
                                            ),
                                        child: Text(
                                          'Sign up',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Extra bottom padding for keyboard
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
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    final borderClr = const Color.fromARGB(255, 75, 77, 86);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            // color: const Color(0xFF374151),
            // color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscureText,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 20,
                      color: const Color(0xFF6B7280),
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            // fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderClr),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderClr),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
