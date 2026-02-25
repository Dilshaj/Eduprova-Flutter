import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eduprova/auth/widgets/background_orbits.dart';
import 'package:eduprova/auth/widgets/login_form.dart';
import 'package:eduprova/auth/widgets/signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  void _toggleView() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    // Responsive sizing - Matched across views
    final initialSpacer = size.height * 0.32;
    final compressedSpacer = size.height * 0.10;
    final currentSpacer = isKeyboardOpen ? compressedSpacer : initialSpacer;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false, // Handle padding manually
      body: Stack(
        children: [
          // Background Orbits - Static across transitions
          const Positioned.fill(child: BackgroundOrbits()),

          // Top Left Logos - Static across transitions
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 24,
            child: Row(
              children: [
                Image.asset(
                  'assets/Eduprova_logo.png',
                  height: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/Eduprova.png',
                  height: 24,
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

              // Card Container with AnimatedSwitcher
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.05),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: SingleChildScrollView(
                      key: ValueKey<bool>(_showLogin),
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: _showLogin
                          ? LoginForm(onSignupTap: _toggleView)
                          : SignupForm(onLoginTap: _toggleView),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
