import 'dart:ui';

import 'package:flutter/material.dart';

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
