import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VoiceAnalysisBars extends StatelessWidget {
  final double speechLevel;
  final bool isListening;

  const VoiceAnalysisBars({
    super.key,
    required this.speechLevel,
    required this.isListening,
  });

  @override
  Widget build(BuildContext context) {
    if (!isListening) {
      return Row(
        children: List.generate(
          3,
          (dotIndex) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFD946EF),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 16,
      child: Row(
        children: List.generate(15, (barIndex) {
          double normLevel = 0.0;
          if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
            normLevel = ((speechLevel + 50) / 50).clamp(0.0, 1.0);
          } else {
            normLevel = (speechLevel / 10).clamp(0.0, 1.0);
          }
          final distanceFromCenter = (barIndex - 7).abs().toDouble();
          final weight = 1.0 - (distanceFromCenter / 8.0);
          final jagged = 0.5 + ((barIndex % 3 + 1) * 0.15);
          final height = 4 + (normLevel * 12 * weight * jagged);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 2.5,
            height: height.clamp(4, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFD946EF),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
