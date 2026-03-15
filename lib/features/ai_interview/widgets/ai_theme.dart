import 'package:flutter/material.dart';

/// Semantic color tokens for AI Interview pages.
/// Usage inside build():
///   final t = AiTheme.of(context);
///   Container(color: t.bg)
class AiTheme {
  final bool isDark;

  const AiTheme._(this.isDark);

  factory AiTheme.of(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return AiTheme._(brightness == Brightness.dark);
  }

  // ── Scaffold / page backgrounds ────────────────────────────────────────────
  Color get scaffoldBg =>
      isDark ? const Color(0xFF0D0D16) : const Color(0xFFFBFCFF);

  Color get scaffoldBgAlt =>
      isDark ? const Color(0xFF111118) : const Color(0xFFF1F1F6);

  // ── Card / surface ──────────────────────────────────────────────────────────
  Color get cardBg => isDark ? const Color(0xFF1A1A28) : Colors.white;

  Color get cardBorder =>
      isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100;

  List<BoxShadow> get cardShadow => isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];

  // ── Text ────────────────────────────────────────────────────────────────────
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF0F172A);

  Color get textSecondary =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

  Color get textMuted =>
      isDark ? const Color(0xFF6B7280) : Colors.grey.shade400;

  // ── Input field ─────────────────────────────────────────────────────────────
  Color get inputBg => isDark ? const Color(0xFF1E1E2E) : Colors.white;

  Color get inputBorder =>
      isDark ? Color.fromARGB(255, 45, 45, 45) : Colors.grey.shade200;

  Color get inputHint =>
      isDark ? const Color(0xFF6B7280) : Colors.grey.shade400;

  // ── Divider ─────────────────────────────────────────────────────────────────
  Color get divider =>
      isDark ? const Color.fromARGB(255, 45, 45, 45) : Colors.grey.shade100;

  // ── Chip / badge ─────────────────────────────────────────────────────────────
  Color get chipBg => isDark ? const Color(0xFF1E1E2E) : Colors.white;

  Color get chipBorder => isDark
      ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
      : const Color(0xFF3B82F6).withValues(alpha: 0.2);

  // ── Blob background circles ──────────────────────────────────────────────────
  double get blobAlpha => isDark ? 0.18 : 0.1;

  // ── Shimmer effect ───────────────────────────────────────────────────────────
  Color get shimmerBase =>
      isDark ? const Color(0xFF2D2D3E) : Colors.grey.shade300;

  Color get shimmerHighlight =>
      isDark ? const Color(0xFF3D3D52) : Colors.grey.shade100;

  // ── Skill bar track ─────────────────────────────────────────────────────────
  Color get barTrack =>
      isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100;

  // ── Icon on bg ──────────────────────────────────────────────────────────────
  Color get iconBack => isDark ? Colors.grey.shade400 : Colors.grey.shade700;

  // ── Score gauge ring track ──────────────────────────────────────────────────
  Color get gaugeTrack =>
      isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100;

  // ── Background Blobs ───────────────────────────────────────────────────────
  Color get blobTopRight => isDark
      ? const Color(0xFF1E3A8A).withValues(alpha: 0.15) // Deep blue
      : const Color.fromARGB(255, 225, 235, 255);

  Color get blobBottomLeft => isDark
      // ? const Color(0xFF312E81).withValues(alpha: 0.15) // Indigo
      ? const Color(0xFF312E81).withValues(alpha: 0.15) // Indigo
      : const Color.fromARGB(255, 238, 233, 243).withValues(alpha: 0.7);

  Color get blobMiddleRight => isDark
      // ? const Color(0xFF1E1B4B).withValues(alpha: 0.15) // Dark indigo
      ? const Color.fromARGB(255, 50, 27, 75).withValues(
          alpha: 0.15,
        ) // Dark indigo
      : Colors.white.withValues(alpha: 0.8);
}
