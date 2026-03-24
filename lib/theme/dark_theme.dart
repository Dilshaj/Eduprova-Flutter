import 'package:eduprova/theme/theme_model.dart';
import 'package:eduprova/theme/messages_theme_extension.dart';
import 'package:flutter/material.dart';

const _gradientStart = Color(0xFF0066FF);
const _gradientEnd = Color(0xFFE056FD);
const _dividerColor = Color(0xFF374151);
const _colorSchema = ColorScheme.dark(
  primary: Color(0xFF155DFC),
  onPrimary: Colors.white,
  secondary: Color(0xFF818CF8),
  onSecondary: Colors.white,

  surface: Color(0xFF1F2937),
  onSurface: Colors.white,

  surfaceContainerLowest: Color(0xFF414B5E),
  surfaceContainerLow: Color(0xFF374151),
  surfaceContainer: Color(0xFF2D3748),
  surfaceContainerHigh: Color(0xFF293241),
  // surfaceContainerHighest: Color(0xFF212B39), // uses for inputs bg
  surfaceContainerHighest: Color(0xFF0D0D16),

  error: Colors.redAccent,
  onError: Colors.white,
);

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

final _messagesDarkColors = MessagesThemeExtension(
  scaffoldBackground: const Color(0xFF121212),
  titleColor: Colors.white,
  searchBarFillColor: const Color(0xFF1F2937),
  searchBarIconColor: const Color(0xFF9CA3AF),
  searchBarTextColor: const Color(0xFF9CA3AF),
  tabSelectedBackground: const Color(0xFF0066FF),
  tabSelectedTextColor: Colors.white,
  tabUnselectedBackground: const Color(0xFF1F2937),
  tabUnselectedTextColor: const Color(0xFF9CA3AF),
  sectionHeaderColor: const Color(0xFF9CA3AF),
  chatTitleColor: Colors.white,
  chatSubtitleColor: const Color(0xFF9CA3AF),
  chatTimeColor: const Color(0xFFE8EAED),
  unreadBadgeBackground: const Color(0xFF0066FF),
  unreadBadgeTextColor: Colors.white,
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: _colorSchema,
  scaffoldBackgroundColor: const Color(0xFF121212),
  dividerColor: _dividerColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: _colorSchema.surfaceContainerHighest,
  ),
  dividerTheme: const DividerThemeData(color: _dividerColor),
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
  extensions: [_darkColors, _messagesDarkColors],
);
