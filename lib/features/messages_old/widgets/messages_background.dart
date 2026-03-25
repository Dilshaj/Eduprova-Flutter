import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:eduprova/theme/messages_theme_extension.dart';

class MessagesBackground extends StatefulWidget {
  final Widget child;

  const MessagesBackground({super.key, required this.child});

  @override
  State<MessagesBackground> createState() => _MessagesBackgroundState();
}

class _MessagesBackgroundState extends State<MessagesBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background color
        Positioned.fill(
          child: Container(
            color:
                Theme.of(
                  context,
                ).extension<MessagesThemeExtension>()?.scaffoldBackground ??
                Theme.of(context).scaffoldBackgroundColor,
          ),
        ),

        // Animated Blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                _buildBlob(
                  color: const Color(
                    0xFFF43F5E,
                  ).withValues(alpha: 0.1), // Rose 500
                  top: -50 + 20 * math.sin(_controller.value * 2 * math.pi),
                  left: -50 + 20 * math.cos(_controller.value * 2 * math.pi),
                ),
                _buildBlob(
                  color: const Color(
                    0xFF6366F1,
                  ).withValues(alpha: 0.1), // Indigo 500
                  bottom: -100 + 30 * math.cos(_controller.value * 2 * math.pi),
                  right: -50 + 20 * math.sin(_controller.value * 2 * math.pi),
                ),
                _buildBlob(
                  color: const Color(
                    0xFF3B82F6,
                  ).withValues(alpha: 0.1), // Blue 500
                  top: 200 + 40 * math.sin(_controller.value * 2 * math.pi),
                  right: -100 + 20 * math.cos(_controller.value * 2 * math.pi),
                ),
                _buildBlob(
                  color: const Color(
                    0xFFA855F7,
                  ).withValues(alpha: 0.1), // Purple 500
                  bottom: 150 + 30 * math.sin(_controller.value * 2 * math.pi),
                  left: -80 + 20 * math.cos(_controller.value * 2 * math.pi),
                ),
              ],
            );
          },
        ),

        // The content
        widget.child,
      ],
    );
  }

  Widget _buildBlob({
    required Color color,
    double? top,
    double? left,
    double? right,
    double? bottom,
    double size = 300,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
