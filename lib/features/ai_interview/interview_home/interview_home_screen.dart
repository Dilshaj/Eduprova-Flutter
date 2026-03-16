import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/features/ai_interview/widgets/ai_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiInterviewHomeScreen extends StatefulWidget {
  const AiInterviewHomeScreen({super.key});

  @override
  State<AiInterviewHomeScreen> createState() => _AiInterviewHomeScreenState();
}

class _AiInterviewHomeScreenState extends State<AiInterviewHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Add horizontal constraints to mimic mobile on larger screens perfectly
          double maxWidth = 600;
          double padding = 0;
          if (constraints.maxWidth > maxWidth) {
            padding = (constraints.maxWidth - maxWidth) / 2;
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Stack(
              children: [
                _buildBackground(
                  constraints.maxHeight,
                  constraints.maxWidth > maxWidth
                      ? maxWidth
                      : constraints.maxWidth,
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildSIMChip(),
                        const SizedBox(height: 24),
                        _buildTitles(),
                        const SizedBox(height: 16),
                        _buildSubtitles(),
                        const SizedBox(height: 32),
                        _buildTags(),
                        const SizedBox(height: 40),
                        _buildButtons(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground(double height, double width) {
    final t = AiTheme.of(context);
    return Positioned.fill(
      child: Stack(
        children: [
          // Top right subtle glow
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: width * 0.8,
              height: height * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.blobTopRight,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 100,
                    color: t.blobTopRight,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          // Bottom left brownish soft wave
          Positioned(
            bottom: height * 0.08,
            left: -width * 0.4,
            child: Transform.rotate(
              angle: -0.2, // rotate wave
              child: Container(
                width: width * 1.5,
                height: height * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(width * 1.5, height * 0.4),
                  ),
                  color: t.blobBottomLeft,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 80,
                      color: t.blobBottomLeft.withValues(alpha: 0.5),
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Middle right white soft wave
          Positioned(
            top: height * 0.35,
            right: -width * 0.5,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: width * 1.2,
                height: height * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(width * 1.2, height * 0.3),
                  ),
                  color: t.blobMiddleRight,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 60,
                      color: t.blobMiddleRight.withValues(alpha: 0.5),
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: null,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF9C27B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Eduprova',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: t.textPrimary,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              context.push(AppRoutes.interviewHistory);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(Icons.history, color: t.textMuted, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'HISTORY',
                    style: TextStyle(
                      color: t.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSIMChip() {
    final t = AiTheme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (t.isDark ? const Color(0xFF3B82F6) : Colors.blue)
                .withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6D00), // Orange dot
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'PROFESSIONAL GRADE SIMULATION',
              style: TextStyle(
                color: t.isDark
                    ? const Color(0xFF90CAF9)
                    : const Color(0xFF64B5F6),
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitles() {
    final t = AiTheme.of(context);
    return Column(
      children: [
        Text(
          'Practice With\nPurpose.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: t.textPrimary,
            height: 1.05,
            letterSpacing: -1.0,
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF0066FF),
              Color(0xFFE056FD),
            ], // Blue to pink/purple gradient
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Interview with\nPrecision',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white, // Color needed for shader mask to work
              height: 1.05,
              letterSpacing: -1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitles() {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'Experience immersive, voice-driven\ntechnical interviews adapted to your\nspecific tech stack.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: t.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTagNode(
              Icons.bolt,
              const Color(0xFFFF9800),
              'AI-Powered',
              Colors.orange.shade50,
            ),
            const SizedBox(width: 12),
            _buildTagNode(
              Icons.insert_chart_outlined,
              const Color(0xFF42A5F5),
              'Actionable Feedback',
              Colors.blue.shade50,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTagNode(
          Icons.edit_document,
          const Color(0xFFAB47BC),
          'Tailored Questions',
          Colors.purple.shade50,
        ),
      ],
    );
  }

  Widget _buildTagNode(
    IconData icon,
    Color iconColor,
    String text,
    Color bgColor,
  ) {
    final t = AiTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: t.isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: t.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: t.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Start Session Gradient Button
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: null,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0066FF),
                  Color(0xFFE056FD),
                ], // Blue to Pink gradient
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD946EF).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                context.push(AppRoutes.aiInterviewSetup);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Session',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bottom Buttons Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color:
                        (t.isDark
                                ? const Color(0xFFE040FB)
                                : const Color(0xFFE040FB))
                            .withValues(alpha: 0.12),
                    border: Border.all(
                      color:
                          (t.isDark
                                  ? const Color(0xFFE040FB)
                                  : const Color(0xFFE040FB))
                              .withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        context.push(AppRoutes.interviewLiveAgent);
                      },
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            'Live Agent',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: t.isDark
                                  ? const Color(0xFFF06292)
                                  : const Color(0xFFD500F9),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: t.isDark
                                ? const Color(0xFFF06292)
                                : const Color(0xFFD500F9),
                            size: 18,
                          ),
                        ],
                      ),
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
