import 'dart:ui';

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        return Stack(
          children: [
            Positioned(
              top: -height * 0.1,
              left: -width * 0.1,
              child: Container(
                width: width * 0.7,
                height: width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              top: height * 0.2,
              right: -width * 0.2,
              child: Container(
                width: width * 0.8,
                height: width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.1,
              left: -width * 0.2,
              child: Container(
                width: width * 0.8,
                height: width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -height * 0.1,
              right: -width * 0.1,
              child: Container(
                width: width * 0.7,
                height: width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA855F7).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}
