import 'package:flutter/material.dart';

class MessagesThemeExtension extends ThemeExtension<MessagesThemeExtension> {
  final Color scaffoldBackground;
  final Color titleColor;
  final Color searchBarFillColor;
  final Color searchBarIconColor;
  final Color searchBarTextColor;
  final Color tabSelectedBackground;
  final Color tabSelectedTextColor;
  final Color tabUnselectedBackground;
  final Color tabUnselectedTextColor;
  final Color sectionHeaderColor;
  final Color chatTitleColor;
  final Color chatSubtitleColor;
  final Color chatTimeColor;
  final Color unreadBadgeBackground;
  final Color unreadBadgeTextColor;

  MessagesThemeExtension({
    required this.scaffoldBackground,
    required this.titleColor,
    required this.searchBarFillColor,
    required this.searchBarIconColor,
    required this.searchBarTextColor,
    required this.tabSelectedBackground,
    required this.tabSelectedTextColor,
    required this.tabUnselectedBackground,
    required this.tabUnselectedTextColor,
    required this.sectionHeaderColor,
    required this.chatTitleColor,
    required this.chatSubtitleColor,
    required this.chatTimeColor,
    required this.unreadBadgeBackground,
    required this.unreadBadgeTextColor,
  });

  @override
  ThemeExtension<MessagesThemeExtension> copyWith({
    Color? scaffoldBackground,
    Color? titleColor,
    Color? searchBarFillColor,
    Color? searchBarIconColor,
    Color? searchBarTextColor,
    Color? tabSelectedBackground,
    Color? tabSelectedTextColor,
    Color? tabUnselectedBackground,
    Color? tabUnselectedTextColor,
    Color? sectionHeaderColor,
    Color? chatTitleColor,
    Color? chatSubtitleColor,
    Color? chatTimeColor,
    Color? unreadBadgeBackground,
    Color? unreadBadgeTextColor,
  }) {
    return MessagesThemeExtension(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      titleColor: titleColor ?? this.titleColor,
      searchBarFillColor: searchBarFillColor ?? this.searchBarFillColor,
      searchBarIconColor: searchBarIconColor ?? this.searchBarIconColor,
      searchBarTextColor: searchBarTextColor ?? this.searchBarTextColor,
      tabSelectedBackground:
          tabSelectedBackground ?? this.tabSelectedBackground,
      tabSelectedTextColor: tabSelectedTextColor ?? this.tabSelectedTextColor,
      tabUnselectedBackground:
          tabUnselectedBackground ?? this.tabUnselectedBackground,
      tabUnselectedTextColor:
          tabUnselectedTextColor ?? this.tabUnselectedTextColor,
      sectionHeaderColor: sectionHeaderColor ?? this.sectionHeaderColor,
      chatTitleColor: chatTitleColor ?? this.chatTitleColor,
      chatSubtitleColor: chatSubtitleColor ?? this.chatSubtitleColor,
      chatTimeColor: chatTimeColor ?? this.chatTimeColor,
      unreadBadgeBackground:
          unreadBadgeBackground ?? this.unreadBadgeBackground,
      unreadBadgeTextColor: unreadBadgeTextColor ?? this.unreadBadgeTextColor,
    );
  }

  @override
  ThemeExtension<MessagesThemeExtension> lerp(
    ThemeExtension<MessagesThemeExtension>? other,
    double t,
  ) {
    if (other is! MessagesThemeExtension) return this;
    return MessagesThemeExtension(
      scaffoldBackground: Color.lerp(
        scaffoldBackground,
        other.scaffoldBackground,
        t,
      )!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      searchBarFillColor: Color.lerp(
        searchBarFillColor,
        other.searchBarFillColor,
        t,
      )!,
      searchBarIconColor: Color.lerp(
        searchBarIconColor,
        other.searchBarIconColor,
        t,
      )!,
      searchBarTextColor: Color.lerp(
        searchBarTextColor,
        other.searchBarTextColor,
        t,
      )!,
      tabSelectedBackground: Color.lerp(
        tabSelectedBackground,
        other.tabSelectedBackground,
        t,
      )!,
      tabSelectedTextColor: Color.lerp(
        tabSelectedTextColor,
        other.tabSelectedTextColor,
        t,
      )!,
      tabUnselectedBackground: Color.lerp(
        tabUnselectedBackground,
        other.tabUnselectedBackground,
        t,
      )!,
      tabUnselectedTextColor: Color.lerp(
        tabUnselectedTextColor,
        other.tabUnselectedTextColor,
        t,
      )!,
      sectionHeaderColor: Color.lerp(
        sectionHeaderColor,
        other.sectionHeaderColor,
        t,
      )!,
      chatTitleColor: Color.lerp(chatTitleColor, other.chatTitleColor, t)!,
      chatSubtitleColor: Color.lerp(
        chatSubtitleColor,
        other.chatSubtitleColor,
        t,
      )!,
      chatTimeColor: Color.lerp(chatTimeColor, other.chatTimeColor, t)!,
      unreadBadgeBackground: Color.lerp(
        unreadBadgeBackground,
        other.unreadBadgeBackground,
        t,
      )!,
      unreadBadgeTextColor: Color.lerp(
        unreadBadgeTextColor,
        other.unreadBadgeTextColor,
        t,
      )!,
    );
  }
}
