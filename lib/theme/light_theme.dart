import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';

const _gradientStart = Color(0xFF0066FF);
const _gradientEnd = Color(0xFFE056FD);

final _lightThemeColors = AppDesignExtension(
  cardColor: Colors.white,
  borderColor: const Color(0xFFE5E7EB),
  secondaryText: const Color(0xFF6B7280),
  shadowColor: Colors.black.withValues(alpha: 0.05),
  saleColor: const Color(0xFFFF3D00),
  skeletonBase: const Color(0xFFF3F4F6),
  skeletonHighlight: Colors.white,
  // accentGradient: const LinearGradient(
  //   colors: [Color(0xFF7F5EFF), Color(0xFFC554F4)],
  // ),
  buyNowGradient: const LinearGradient(colors: [_gradientStart, _gradientEnd]),
  gradiantEnd: _gradientEnd,
  gradiantStart: _gradientStart,
  purpleAccentColor: const Color(0xFFF3E8FF),
  purpleAccentTextColor: const Color(0xFFA020F0),
  progressBarBackgroundColor: const Color(0xFFF3F4F6),
  avatarBackgroundColor: const Color(0xFFF3F4F6),
  iconColor: const Color(0xFF3D5CFF),
  bestsellerBadgeColor: const Color(0xFFECEBFF),
  bestsellerBadgeTextColor: const Color(0xFF3D5CFF),
  beginnerBadgeColor: const Color(0xFFE6F9F0),
  beginnerBadgeTextColor: const Color(0xFF00B87C),
  warningColor: const Color(0xFFFFB800),
  successColor: const Color(0xFF00C853),
  successBackgroundColor: const Color(0xFFF0FDF4),
  errorBackgroundColor: const Color(0xFFFEF2F2),
  hotBadgeColor: const Color(0xFFFF6B6B),
  hotBadgeTextColor: Colors.white,
  highestRatedBadgeColor: const Color(0xFF4D96FF),
  highestRatedBadgeTextColor: Colors.white,
  discountBackgroundColor: const Color(0xFFE8F5E9),
  discountTextColor: const Color(0xFF2E7D32),
  readMoreColor: const Color(0xFF0066FF),
  scaffoldBackgroundColor: Colors.white,
);

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF3B82F6),
    onPrimary: Colors.white,
    secondary: Color(0xFF7F5EFF),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Color(0xFF111827),
    error: Colors.red,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  // scaffoldBackgroundColor: const Color.fromARGB(255, 248, 248, 248),
  dividerColor: const Color(0xFFE5E7EB),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF111827),
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      // color: Color(0xFF111827),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  extensions: [_lightThemeColors],
);
