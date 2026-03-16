import 'dart:ui';

import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';

const _gradientStart = Color(0xFF0066FF);
const _gradientEnd = Color(0xFFE056FD);

final _darkColors = AppDesignExtension(
  // cardColor: const Color(0xFF1F2937),
  // cardColor: const Color(0xFF171F29),
  cardColor: const Color(0xFF1A1A28),
  // borderColor: const Color(0xFF374151),
  borderColor: const Color.fromARGB(255, 44, 51, 64),
  secondaryText: const Color(0xFF9CA3AF),
  shadowColor: Colors.black.withValues(alpha: 0.3),
  saleColor: const Color(0xFFFB923C),
  skeletonBase: const Color(0xFF1F2937),
  skeletonHighlight: const Color(0xFF374151),

  // accentGradient: const LinearGradient(
  //   colors: [Color(0xFF7F5EFF), Color(0xFFC554F4)],
  // ),
  buyNowGradient: const LinearGradient(colors: [_gradientStart, _gradientEnd]),
  gradiantEnd: _gradientEnd,
  gradiantStart: _gradientStart,
  purpleAccentColor: const Color(0xFFA020F0).withValues(alpha: 0.2),
  purpleAccentTextColor: const Color(0xFFC084FC),
  progressBarBackgroundColor: const Color(0xFF374151),
  avatarBackgroundColor: const Color(0xFF374151),
  iconColor: const Color(0xFF60A5FA),
  bestsellerBadgeColor: const Color(0xFF312E81).withValues(alpha: 0.5),
  bestsellerBadgeTextColor: const Color(0xFF818CF8),
  beginnerBadgeColor: const Color(0xFF064E3B).withValues(alpha: 0.5),
  beginnerBadgeTextColor: const Color(0xFF34D399),
  warningColor: const Color(0xFFFFB800),
  successColor: const Color(0xFF00E676),
  successBackgroundColor: const Color(0xFF064E3B).withValues(alpha: 0.2),
  errorBackgroundColor: const Color(0xFF7F1D1D).withValues(alpha: 0.2),
  hotBadgeColor: const Color(0xFF991B1B),
  hotBadgeTextColor: const Color(0xFFFECACA),
  highestRatedBadgeColor: const Color(0xFF1E3A8A),
  highestRatedBadgeTextColor: const Color(0xFFBFDBFE),
  discountBackgroundColor: const Color(0xFF064E3B).withValues(alpha: 0.2),
  discountTextColor: const Color(0xFF34D399),
  readMoreColor: const Color(0xFF60A5FA),
  scaffoldBackgroundColor: const Color(0xFF121212),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3B82F6),
    onPrimary: Colors.white,
    secondary: Color(0xFF818CF8),
    onSecondary: Colors.white,
    surface: Color(0xFF1F2937),
    onSurface: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  dividerColor: const Color(0xFF374151),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  // use styles like basic Input:
  // inputDecorationTheme: InputDecorationTheme(
  //   filled: true,
  //   fillColor: Colors.white,
  //   border: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(10),
  //     borderSide: BorderSide(color: Colors.grey.shade300),
  //   ),
  //   enabledBorder: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(10),
  //     borderSide: BorderSide(color: Colors.grey.shade300),
  //   ),
  //   focusedBorder: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(10),
  //     borderSide: BorderSide(color: Colors.blue.shade400),
  //   ),
  //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  // ),
  extensions: [_darkColors],
);
