import 'dart:math' as math;
import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class GrammarHomeScreen extends StatefulWidget {
  const GrammarHomeScreen({super.key});

  @override
  State<GrammarHomeScreen> createState() => _GrammarHomeScreenState();
}

class _GrammarHomeScreenState extends State<GrammarHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: .symmetric(vertical: 60, horizontal: 20),
        child: Column(
          children: [
            // Badge
            _buildBadge(),
            const SizedBox(height: 30),

            // Hero Title
            Text(
              'Master English With',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                letterSpacing: -1,
              ),
              textAlign: .center,
            ),

            // Gradient Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFFE056FD)],
              ).createShader(bounds),
              child: Text(
                'Ai Grammar Assistant',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: -1,
                ),
                textAlign: .center,
              ),
            ),

            const SizedBox(height: 20),

            // Sub-headline
            Padding(
              padding: .symmetric(horizontal: 20),
              child: Text(
                'AI Grammar Assistant that instantly corrects mistakes and helps you write and speak English with confidence.',
                style: TextStyle(
                  fontSize: 14,
                  color: themeExt.secondaryText,
                  height: 1.5,
                ),
                textAlign: .center,
              ),
            ),

            const SizedBox(height: 40),

            // Get Started Button
            _buildGetStartedButton(),

            const SizedBox(height: 60),

            // Circular Layout
            _buildCircularLayout(),

            const SizedBox(height: 60),

            // Feature Cards
            _buildFeatureCards(themeExt),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: .symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
        borderRadius: .circular(20),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: .circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'THE FUTURE OF FLUENCY',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return const RocketLaunchButton();
  }

  // Fixed rectangular canvas so absolute Positioned math always works.
  // Extra height at the bottom prevents icon labels from being clipped.
  static const double _canvasW = 360;
  static const double _canvasH = 420;
  static const double _iconRadius = 130; // Reduced radius
  static const double _cx = _canvasW / 2; // 180
  static const double _cy = _canvasH / 2 - 10; // 200 — slightly above center
  static const double _iconW = 68;
  static const double _iconH = 90; // card (68) + gap (6) + label (16)

  Widget _buildCircularLayout() {
    return Center(
      child: SizedBox(
        width: _canvasW,
        height: _canvasH,
        child: Stack(
          children: [
            // Dashed circles — painted around the actual center
            CustomPaint(
              size: const Size(_canvasW, _canvasH),
              painter: CirclePainter(cx: _cx, cy: _cy, iconRadius: _iconRadius),
            ),

            // Outer soft glow — centered at _cx, _cy
            Positioned(
              left: _cx - 100,
              top: _cy - 100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: .circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.18),
                      const Color(0xFFE056FD).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Central Bot Circle — centered at _cx, _cy
            Positioned(
              left: _cx - 60,
              top: _cy - 60,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: .circle,
                  gradient: LinearGradient(
                    begin: .topLeft,
                    end: .bottomRight,
                    colors: [
                      const Color(0xFF93C5FD).withValues(alpha: 0.35),
                      const Color(0xFFC4B5FD).withValues(alpha: 0.25),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/grammar-assistant/ai-bot.png',
                    width: 85,
                    height: 85,
                    fit: .contain,
                  ),
                ),
              ),
            ),

            // Animated orbiting icons
            AnimatedBuilder(
              animation: _orbitController,
              builder: (context, _) {
                final orbitAngle = _orbitController.value * 2 * math.pi;
                return Stack(children: _buildCircularFeatures(orbitAngle));
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCircularFeatures(double orbitAngle) {
    final List<(String, IconData, Color)> features = [
      (
        'CONVERSATION',
        Icons.chat_bubble_outline_rounded,
        const Color(0xFF0066FF),
      ),
      ('REFINER', Icons.auto_awesome_rounded, const Color(0xFFE056FD)),
      ('LIVE COACH', Icons.smart_toy_outlined, const Color(0xFF3E4EA0)),
      // ('PRESENTATION', Icons.person_pin_outlined, const Color(0xFFE056FD)),
      ('SHADOWING', Icons.settings_voice_outlined, const Color(0xFF3B82F6)),
      ('ROLEPLAY', Icons.theater_comedy_outlined, const Color(0xFFE056FD)),
    ];

    return [
      for (var (i, feature) in features.indexed)
        _buildCircularIcon(
          i,
          features.length,
          feature.$1,
          feature.$2,
          feature.$3,
          orbitAngle,
          context,
        ),
    ];
  }

  Widget _buildCircularIcon(
    int index,
    int total,
    String label,
    IconData icon,
    Color color,
    double orbitAngle, // current orbit rotation in radians
    BuildContext context,
  ) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    // Each icon starts at its base angle, then adds the global orbit angle
    final baseAngle = (index * 2 * math.pi / total) - (math.pi / 2);
    final angle = baseAngle + orbitAngle;
    final x = math.cos(angle) * _iconRadius;
    final y = math.sin(angle) * _iconRadius;

    return Positioned(
      left: _cx + x - (_iconW / 2),
      top: _cy + y - (_iconH / 2),
      width: _iconW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _iconW,
            height: _iconW,
            decoration: BoxDecoration(
              color: themeExt.cardColor,
              borderRadius: .circular(18),
              border: .all(color: color.withValues(alpha: 0.12), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: themeExt.shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: .circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: .center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(AppDesignExtension themeExt) {
    return Column(
      children: [
        _buildFeatureCard(
          '10ms Latency',
          'Near-instant spatial voice processing for natural flow.',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          '3D Spatial Audio',
          'Immerse your ears in directional coaching environments.',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          '98% Accuracy',
          'Precision accent and grammar correction engine.',
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: .all(32),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: .circular(42),
        border: .all(color: themeExt.borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: themeExt.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 18,
              color: themeExt.secondaryText,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class RocketLaunchButton extends StatefulWidget {
  const RocketLaunchButton({super.key});

  @override
  State<RocketLaunchButton> createState() => _RocketLaunchButtonState();
}

class _RocketLaunchButtonState extends State<RocketLaunchButton>
    with TickerProviderStateMixin {
  late AnimationController _launchController;
  late AnimationController _flameController;
  late Animation<Offset> _rocketPosition;
  late Animation<double> _rocketOpacity;
  late Animation<double> _rocketScale;
  bool _isLaunched = false;

  @override
  void initState() {
    super.initState();
    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);

    _rocketPosition =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(8.0, -8.0), // Fly up and right out of screen
        ).animate(
          CurvedAnimation(
            parent: _launchController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeInCirc),
          ),
        );

    _rocketOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _rocketScale =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(
              begin: 1.0,
              end: 0.85,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 20,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: 0.85,
              end: 1.5,
            ).chain(CurveTween(curve: Curves.easeInQuad)),
            weight: 80,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _launchController,
            curve: const Interval(0.0, 0.4),
          ),
        );
  }

  @override
  void dispose() {
    _launchController.dispose();
    _flameController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLaunched) return;
    setState(() => _isLaunched = true);

    await _launchController.forward();
    if (mounted) {
      context.pushNamed('grammar_conversation');
      // Reset after transition for when user comes back
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _launchController.reset();
          setState(() => _isLaunched = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedBuilder(
                animation: Listenable.merge([
                  _launchController,
                  _flameController,
                ]),
                builder: (context, child) {
                  double offsetX = 0;
                  double offsetY = 0;

                  // Intense rumble effect before takeoff
                  if (_isLaunched && _launchController.value < 0.2) {
                    final progress = _launchController.value / 0.2;
                    final intensity = math.sin(progress * math.pi);
                    offsetX =
                        (math.Random().nextDouble() - 0.5) * 6 * intensity;
                    offsetY =
                        (math.Random().nextDouble() - 0.5) * 6 * intensity;
                  }

                  return Transform.translate(
                    offset: Offset(offsetX, offsetY),
                    child: Transform.translate(
                      offset: _rocketPosition.value * 30, // Distance traveled
                      child: Transform.scale(
                        scale: _rocketScale.value,
                        child: Opacity(
                          opacity: _rocketOpacity.value,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Particle Flames & Smoke
                              if (_isLaunched)
                                Positioned.fill(
                                  child: CustomPaint(
                                    size: const Size(22, 22),
                                    painter: FlamePainter(
                                      progress: _launchController.value,
                                      flicker: _flameController.value,
                                      isLaunched: _isLaunched,
                                    ),
                                  ),
                                ),
                              // Rocket
                              const Icon(
                                Icons.rocket_launch_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlamePainter extends CustomPainter {
  final double progress;
  final double flicker;
  final bool isLaunched;

  FlamePainter({
    required this.progress,
    required this.flicker,
    required this.isLaunched,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isLaunched || progress > 0.95) return;

    double fireScale = progress < 0.2 ? progress * 5.0 : 1.0 + (progress * 0.5);

    final paint = Paint()..style = PaintingStyle.fill;

    // The rocket nozzle in `rocket_launch_rounded` is at bottom-left roughly
    final Offset nozzle = Offset(size.width * 0.1, size.height * 0.9);

    canvas.save();
    canvas.translate(nozzle.dx, nozzle.dy);
    // Angle pointing down-left (approx 135 deg = 2.356 radians)
    canvas.rotate(2.356);

    double fireLength = 24.0 * fireScale + (flicker * 6.0);
    double fireWidth = 10.0 * fireScale + (flicker * 2.0);

    // Inner to outer layers of flame
    paint.color = Colors.red.withValues(alpha: 0.7 * (1 - progress));
    _drawFlameShape(canvas, fireLength * 1.5, fireWidth * 1.5, paint);

    paint.color = Colors.orange.withValues(alpha: 0.9 * (1 - progress));
    _drawFlameShape(canvas, fireLength * 1.2, fireWidth * 1.2, paint);

    paint.color = Colors.yellow;
    _drawFlameShape(canvas, fireLength * 0.8, fireWidth * 0.8, paint);

    canvas.restore();

    // Dynamic smoke particles
    if (progress > 0.1) {
      final smokePaint = Paint()..style = PaintingStyle.fill;
      final random = math.Random(
        1234,
      ); // Seeded for consistent but random-looking particles

      for (int i = 0; i < 15; i++) {
        double angle = 2.356 + (random.nextDouble() - 0.5) * 1.2; // Cone spread
        double speed = 20.0 + random.nextDouble() * 60.0;
        // Particles travel progressively further based on launch progress
        double dist = ((progress - 0.1) / 0.9) * speed * 2;

        double sx = nozzle.dx + math.cos(angle) * dist;
        double sy = nozzle.dy + math.sin(angle) * dist;

        double particleSize = 4.0 + random.nextDouble() * 6.0 + (progress * 12);
        // Fade out smoke as it expands
        double opacity = math.max(
          0.0,
          1.0 - (progress * 1.5) - random.nextDouble() * 0.2,
        );

        if (opacity > 0) {
          smokePaint.color = Colors.white.withValues(alpha: opacity * 0.5);
          canvas.drawCircle(Offset(sx, sy), particleSize, smokePaint);

          // Inner grey smoke
          smokePaint.color = Colors.grey.withValues(alpha: opacity * 0.3);
          canvas.drawCircle(Offset(sx, sy), particleSize * 0.6, smokePaint);
        }
      }
    }
  }

  void _drawFlameShape(
    Canvas canvas,
    double length,
    double width,
    Paint paint,
  ) {
    final Path path = Path();
    path.moveTo(0, 0);
    // Creates a teardrop flame pointing rightwards along X-axis
    path.quadraticBezierTo(length * 0.6, width * 0.5, length, 0);
    path.quadraticBezierTo(length * 0.6, -width * 0.5, 0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FlamePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.flicker != flicker ||
        oldDelegate.isLaunched != isLaunched;
  }
}

class CirclePainter extends CustomPainter {
  final double cx;
  final double cy;
  final double iconRadius;
  const CirclePainter({
    required this.cx,
    required this.cy,
    required this.iconRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(cx, cy);

    final mainPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final glowPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Inner dashed circle
    _drawDashedCircle(canvas, center, iconRadius * 0.65, mainPaint);
    // Outer dashed circle (matches icon orbit radius)
    _drawDashedCircle(canvas, center, iconRadius, glowPaint);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const dashWidth = 4.0;
    const dashSpace = 6.0;
    final circumference = 2 * math.pi * radius;
    final double dashCount = (circumference / (dashWidth + dashSpace))
        .floorToDouble();
    for (var i = 0; i < dashCount; i++) {
      final double startAngle =
          (i * (dashWidth + dashSpace) / circumference) * 2 * math.pi;
      final double sweepAngle = (dashWidth / circumference) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CirclePainter old) =>
      old.cx != cx || old.cy != cy || old.iconRadius != iconRadius;
}
