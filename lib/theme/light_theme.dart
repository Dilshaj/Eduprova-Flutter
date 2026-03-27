import 'package:eduprova/theme/theme_model.dart';
import 'package:eduprova/theme/messages_theme_extension.dart';
import 'package:flutter/material.dart';

const _gradientStart = Color(0xFF0066FF);
const _gradientEnd = Color(0xFFE056FD);
const _dividerColor = Color(0xFFE5E7EB);

final _colorSchema = const ColorScheme.light(
  primary: Color(0xFF155DFC),
  onPrimary: Colors.white,
  secondary: Color(0xFF7F5EFF),
  onSecondary: Colors.white,
  surface: Colors.white,
  surfaceContainer: Color(0xFFF1F5F9),
  surfaceContainerHighest: Color(0xFFF4F9Fd),
  onSurface: Color(0xFF111827),
  error: Colors.red,
  onError: Colors.white,
);

final _themeColors = AppDesignExtension(
  cardColor: Colors.white,
  borderColor: _dividerColor,
  secondaryText: const Color(0xFF6B7280),
  shadowColor: Colors.black.withValues(alpha: 0.05),
  saleColor: const Color(0xFFFF3D00),
  skeletonBase: const Color(0xFFF3F4F6),
  skeletonHighlight: Colors.white,
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

final _messagesLightColors = MessagesThemeExtension(
  scaffoldBackground: const Color(0xFFFBFCFF),
  titleColor: Colors.black,
  searchBarFillColor: Colors.white,
  searchBarIconColor: const Color(0xFF6B7280),
  searchBarTextColor: const Color(0xFF6B7280),
  tabSelectedBackground: const Color(0xFF0066FF),
  tabSelectedTextColor: Colors.white,
  tabUnselectedBackground: Colors.white,
  tabUnselectedTextColor: const Color(0xFF6B7280),
  sectionHeaderColor: const Color(0xFF6B7280),
  chatTitleColor: Colors.black,
  chatSubtitleColor: const Color(0xFF6B7280),
  chatTimeColor: const Color(0xFF111111),
  unreadBadgeBackground: const Color(0xFF0066FF),
  unreadBadgeTextColor: Colors.white,
);

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: _colorSchema,
  scaffoldBackgroundColor: Colors.white,
  dividerColor: _dividerColor,
  dividerTheme: const DividerThemeData(color: _dividerColor),
  extensions: [_themeColors, _messagesLightColors],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF111827),
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Color(0xFF111827),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: _colorSchema.surfaceContainerHighest,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: _colorSchema.surfaceContainerLowest,
    selectedColor: Color(0xFF0066FF),
    disabledColor: Color(0xFF374151),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      side: BorderSide(color: _dividerColor),
    ),
    labelStyle: TextStyle(color: Colors.white),
  ),
  tabBarTheme: TabBarThemeData(dividerColor: _dividerColor),
);
