import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    // const gradientStart = Color(0xFF7F5EFF);
    const gradientStart = Color(0xFF0066FF);
    const gradientEnd = Color(0xFFE056FD);
    return ThemeData(
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
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF111827),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      extensions: [
        AppDesignExtension(
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
          buyNowGradient: const LinearGradient(
            colors: [gradientStart, gradientEnd],
          ),
          gradiantEnd: gradientEnd,
          gradiantStart: gradientStart,
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
        ),
      ],
    );
  }

  static ThemeData dark() {
    // const gradientStart = Color(0xFF0066FF);
    const gradientStart = Color(0xFF0066FF);
    const gradientEnd = Color(0xFFE056FD);
    return ThemeData(
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
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      extensions: [
        AppDesignExtension(
          // cardColor: const Color(0xFF1F2937),
          // cardColor: const Color(0xFF171F29),
          cardColor: const Color(0xFF1A1A28),
          borderColor: const Color(0xFF374151),
          secondaryText: const Color(0xFF9CA3AF),
          shadowColor: Colors.black.withValues(alpha: 0.3),
          saleColor: const Color(0xFFFB923C),
          skeletonBase: const Color(0xFF1F2937),
          skeletonHighlight: const Color(0xFF374151),

          // accentGradient: const LinearGradient(
          //   colors: [Color(0xFF7F5EFF), Color(0xFFC554F4)],
          // ),
          buyNowGradient: const LinearGradient(
            colors: [gradientStart, gradientEnd],
          ),
          gradiantEnd: gradientEnd,
          gradiantStart: gradientStart,
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
          successBackgroundColor: const Color(
            0xFF064E3B,
          ).withValues(alpha: 0.2),
          errorBackgroundColor: const Color(0xFF7F1D1D).withValues(alpha: 0.2),
          hotBadgeColor: const Color(0xFF991B1B),
          hotBadgeTextColor: const Color(0xFFFECACA),
          highestRatedBadgeColor: const Color(0xFF1E3A8A),
          highestRatedBadgeTextColor: const Color(0xFFBFDBFE),
          discountBackgroundColor: const Color(
            0xFF064E3B,
          ).withValues(alpha: 0.2),
          discountTextColor: const Color(0xFF34D399),
          readMoreColor: const Color(0xFF60A5FA),
          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
      ],
    );
  }
}

class AppDesignExtension extends ThemeExtension<AppDesignExtension> {
  final Color cardColor;
  final Color borderColor;
  final Color secondaryText;
  final Color shadowColor;
  final Color saleColor;
  final Color skeletonBase;
  final Color skeletonHighlight;
  // final LinearGradient accentGradient;
  final LinearGradient buyNowGradient;
  final Color gradiantStart;
  final Color gradiantEnd;

  // New specific tokens
  final Color purpleAccentColor;
  final Color purpleAccentTextColor;
  final Color progressBarBackgroundColor;
  final Color avatarBackgroundColor;
  final Color iconColor;
  final Color bestsellerBadgeColor;
  final Color bestsellerBadgeTextColor;
  final Color beginnerBadgeColor;
  final Color beginnerBadgeTextColor;
  final Color warningColor;
  final Color successColor;
  final Color successBackgroundColor;
  final Color errorBackgroundColor;
  final Color hotBadgeColor;
  final Color hotBadgeTextColor;
  final Color highestRatedBadgeColor;
  final Color highestRatedBadgeTextColor;
  final Color discountBackgroundColor;
  final Color discountTextColor;
  final Color readMoreColor;
  final Color scaffoldBackgroundColor;

  AppDesignExtension({
    required this.cardColor,
    required this.borderColor,
    required this.secondaryText,
    required this.shadowColor,
    required this.saleColor,
    required this.skeletonBase,
    required this.skeletonHighlight,
    // required this.accentGradient,
    required this.buyNowGradient,
    required this.gradiantStart,
    required this.gradiantEnd,
    required this.purpleAccentColor,
    required this.purpleAccentTextColor,
    required this.progressBarBackgroundColor,
    required this.avatarBackgroundColor,
    required this.iconColor,
    required this.bestsellerBadgeColor,
    required this.bestsellerBadgeTextColor,
    required this.beginnerBadgeColor,
    required this.beginnerBadgeTextColor,
    required this.warningColor,
    required this.successColor,
    required this.successBackgroundColor,
    required this.errorBackgroundColor,
    required this.hotBadgeColor,
    required this.hotBadgeTextColor,
    required this.highestRatedBadgeColor,
    required this.highestRatedBadgeTextColor,
    required this.discountBackgroundColor,
    required this.discountTextColor,
    required this.readMoreColor,
    required this.scaffoldBackgroundColor,
  });

  @override
  ThemeExtension<AppDesignExtension> copyWith({
    Color? cardColor,
    Color? borderColor,
    Color? secondaryText,
    Color? shadowColor,
    Color? saleColor,
    Color? skeletonBase,
    Color? skeletonHighlight,
    // LinearGradient? accentGradient,
    LinearGradient? buyNowGradient,
    Color? gradiantStart,
    Color? gradiantEnd,
    Color? purpleAccentColor,
    Color? purpleAccentTextColor,
    Color? progressBarBackgroundColor,
    Color? avatarBackgroundColor,
    Color? iconColor,
    Color? bestsellerBadgeColor,
    Color? bestsellerBadgeTextColor,
    Color? beginnerBadgeColor,
    Color? beginnerBadgeTextColor,
    Color? warningColor,
    Color? successColor,
    Color? successBackgroundColor,
    Color? errorBackgroundColor,
    Color? hotBadgeColor,
    Color? hotBadgeTextColor,
    Color? highestRatedBadgeColor,
    Color? highestRatedBadgeTextColor,
    Color? discountBackgroundColor,
    Color? discountTextColor,
    Color? readMoreColor,
    Color? scaffoldBackgroundColor,
  }) {
    return AppDesignExtension(
      cardColor: cardColor ?? this.cardColor,
      borderColor: borderColor ?? this.borderColor,
      secondaryText: secondaryText ?? this.secondaryText,
      shadowColor: shadowColor ?? this.shadowColor,
      saleColor: saleColor ?? this.saleColor,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      // accentGradient: accentGradient ?? this.accentGradient,
      buyNowGradient: buyNowGradient ?? this.buyNowGradient,
      gradiantStart: gradiantStart ?? this.gradiantStart,
      gradiantEnd: gradiantEnd ?? this.gradiantEnd,
      purpleAccentColor: purpleAccentColor ?? this.purpleAccentColor,
      purpleAccentTextColor:
          purpleAccentTextColor ?? this.purpleAccentTextColor,
      progressBarBackgroundColor:
          progressBarBackgroundColor ?? this.progressBarBackgroundColor,
      avatarBackgroundColor:
          avatarBackgroundColor ?? this.avatarBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
      bestsellerBadgeColor: bestsellerBadgeColor ?? this.bestsellerBadgeColor,
      bestsellerBadgeTextColor:
          bestsellerBadgeTextColor ?? this.bestsellerBadgeTextColor,
      beginnerBadgeColor: beginnerBadgeColor ?? this.beginnerBadgeColor,
      beginnerBadgeTextColor:
          beginnerBadgeTextColor ?? this.beginnerBadgeTextColor,
      warningColor: warningColor ?? this.warningColor,
      successColor: successColor ?? this.successColor,
      successBackgroundColor:
          successBackgroundColor ?? this.successBackgroundColor,
      errorBackgroundColor: errorBackgroundColor ?? this.errorBackgroundColor,
      hotBadgeColor: hotBadgeColor ?? this.hotBadgeColor,
      hotBadgeTextColor: hotBadgeTextColor ?? this.hotBadgeTextColor,
      highestRatedBadgeColor:
          highestRatedBadgeColor ?? this.highestRatedBadgeColor,
      highestRatedBadgeTextColor:
          highestRatedBadgeTextColor ?? this.highestRatedBadgeTextColor,
      discountBackgroundColor:
          discountBackgroundColor ?? this.discountBackgroundColor,
      discountTextColor: discountTextColor ?? this.discountTextColor,
      readMoreColor: readMoreColor ?? this.readMoreColor,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
    );
  }

  @override
  ThemeExtension<AppDesignExtension> lerp(
    ThemeExtension<AppDesignExtension>? other,
    double t,
  ) {
    if (other is! AppDesignExtension) return this;
    return AppDesignExtension(
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      saleColor: Color.lerp(saleColor, other.saleColor, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      gradiantStart: Color.lerp(gradiantStart, other.gradiantStart, t)!,
      gradiantEnd: Color.lerp(gradiantEnd, other.gradiantEnd, t)!,
      // accentGradient: LinearGradient.lerp(
      //   accentGradient,
      //   other.accentGradient,
      //   t,
      // )!,
      buyNowGradient: LinearGradient.lerp(
        buyNowGradient,
        other.buyNowGradient,
        t,
      )!,
      purpleAccentColor: Color.lerp(
        purpleAccentColor,
        other.purpleAccentColor,
        t,
      )!,
      purpleAccentTextColor: Color.lerp(
        purpleAccentTextColor,
        other.purpleAccentTextColor,
        t,
      )!,
      progressBarBackgroundColor: Color.lerp(
        progressBarBackgroundColor,
        other.progressBarBackgroundColor,
        t,
      )!,
      avatarBackgroundColor: Color.lerp(
        avatarBackgroundColor,
        other.avatarBackgroundColor,
        t,
      )!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      bestsellerBadgeColor: Color.lerp(
        bestsellerBadgeColor,
        other.bestsellerBadgeColor,
        t,
      )!,
      bestsellerBadgeTextColor: Color.lerp(
        bestsellerBadgeTextColor,
        other.bestsellerBadgeTextColor,
        t,
      )!,
      beginnerBadgeColor: Color.lerp(
        beginnerBadgeColor,
        other.beginnerBadgeColor,
        t,
      )!,
      beginnerBadgeTextColor: Color.lerp(
        beginnerBadgeTextColor,
        other.beginnerBadgeTextColor,
        t,
      )!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      successBackgroundColor: Color.lerp(
        successBackgroundColor,
        other.successBackgroundColor,
        t,
      )!,
      errorBackgroundColor: Color.lerp(
        errorBackgroundColor,
        other.errorBackgroundColor,
        t,
      )!,
      hotBadgeColor: Color.lerp(hotBadgeColor, other.hotBadgeColor, t)!,
      hotBadgeTextColor: Color.lerp(
        hotBadgeTextColor,
        other.hotBadgeTextColor,
        t,
      )!,
      highestRatedBadgeColor: Color.lerp(
        highestRatedBadgeColor,
        other.highestRatedBadgeColor,
        t,
      )!,
      highestRatedBadgeTextColor: Color.lerp(
        highestRatedBadgeTextColor,
        other.highestRatedBadgeTextColor,
        t,
      )!,
      discountBackgroundColor: Color.lerp(
        discountBackgroundColor,
        other.discountBackgroundColor,
        t,
      )!,
      discountTextColor: Color.lerp(
        discountTextColor,
        other.discountTextColor,
        t,
      )!,
      readMoreColor: Color.lerp(readMoreColor, other.readMoreColor, t)!,
      scaffoldBackgroundColor: Color.lerp(
        scaffoldBackgroundColor,
        other.scaffoldBackgroundColor,
        t,
      )!,
    );
  }
}
