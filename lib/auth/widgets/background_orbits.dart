import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class BackgroundOrbits extends StatefulWidget {
  const BackgroundOrbits({super.key});

  @override
  State<BackgroundOrbits> createState() => _BackgroundOrbitsState();
}

class _BackgroundOrbitsState extends State<BackgroundOrbits>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 🔥 Adjusted spacing value
  final double orbitSpacing = 50.0; // ← Reduced gap
  final double baseRadius = 50.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> orbitIcons = [
    {'icon': Brands.google},
    {'icon': Brands.html_5},
    {'icon': Brands.css3},
    {'icon': Brands.javascript},
    {'icon': Brands.react_native},
    {'icon': Brands.java},
    {'icon': Brands.python},
    {'icon': Brands.mysql_logo},
    {'icon': Brands.mongodb},
    {'icon': Brands.flutter},
    {'icon': Brands.kotlin},
    {'icon': Brands.swift_programming},
    {'icon': Brands.docker},
    {'icon': Brands.github},
    {'icon': Brands.php_designer},
    {'icon': Brands.angularjs},
    {'icon': Brands.golang},
    {'icon': Brands.ruby_programming_language},
    {'icon': Brands.typescript},
    {'icon': Brands.jenkins},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = (math.min(size.width, size.height) / 400.0).clamp(0.8, 2.0);

    // Explicit mathematical center for perfect alignment on any screen
    final centerX = size.width / 2;
    // Position slightly towards the top half on portrait
    final centerY = size.height * 0.35;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Animated orbit layers correctly centered and scaled
        _OrbitLayer(
          radius: 95.0 * scale,
          rotationSpeed: 0.15,
          iconData: orbitIcons.sublist(0, 4),
          reverse: false,
          centerX: centerX,
          centerY: centerY,
        ),
        _OrbitLayer(
          radius: 145.0 * scale,
          rotationSpeed: 0.20,
          iconData: orbitIcons.sublist(4, 10),
          reverse: false,
          centerX: centerX,
          centerY: centerY,
        ),
        _OrbitLayer(
          radius: 195.0 * scale,
          rotationSpeed: 0.25,
          iconData: orbitIcons.sublist(10, 20),
          reverse: false,
          centerX: centerX,
          centerY: centerY,
        ),
      ],
    );
  }
}

class _OrbitLayer extends StatefulWidget {
  final double radius;
  final double rotationSpeed;
  final List<Map<String, dynamic>> iconData;
  final bool reverse;
  final double centerX;
  final double centerY;

  const _OrbitLayer({
    required this.radius,
    required this.rotationSpeed,
    required this.iconData,
    this.reverse = false,
    required this.centerX,
    required this.centerY,
  });

  @override
  _OrbitLayerState createState() => _OrbitLayerState();
}

class _OrbitLayerState extends State<_OrbitLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: (20 / widget.rotationSpeed).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.iconData.length;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Orbit Ring - explicitly positioned around target center
            Positioned(
              left: widget.centerX - widget.radius,
              top: widget.centerY - widget.radius,
              child: Container(
                width: widget.radius * 2,
                height: widget.radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
              ),
            ),

            // Orbiting Icons manually aligned exactly to ring coordinates
            ...List.generate(count, (index) {
              final double angle =
                  (2 * math.pi * index / count) +
                  (_controller.value * 2 * math.pi * (widget.reverse ? -1 : 1));
              final double x = widget.radius * math.cos(angle);
              final double y = widget.radius * math.sin(angle);

              return Positioned(
                left: widget.centerX + x - 18,
                top: widget.centerY + y - 18,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  child: Brand(widget.iconData[index]['icon'], size: 18),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class OrbitsPainter extends CustomPainter {
  final Offset center;
  final double orbitSpacing;
  final double baseRadius;
  final Color orbitColor;

  OrbitsPainter({
    required this.center,
    required this.orbitSpacing,
    required this.baseRadius,
    required this.orbitColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = orbitColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 4; i++) {
      final radius = baseRadius + ((i + 1) * orbitSpacing);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
