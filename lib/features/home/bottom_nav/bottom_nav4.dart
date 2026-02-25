import 'package:flutter/material.dart';
import 'package:suryaicons/bulk_rounded.dart';
import 'package:suryaicons/stroke_rounded.dart';
import 'package:suryaicons/suryaicons.dart';

/// Routes that map to each tab — same order as [BottomNav1].
final nav4Routes = [
  (route: '/', label: 'Home'),
  (route: '/courses', label: 'Courses'),
  (route: '/messages', label: 'Messages'),
  (route: '/jobs', label: 'Jobs'),
];

/// Icon pairs: (stroke/outline, bulk/filled) — one per tab, same order.
final _nav4Icons = [
  (outline: StrokeRounded.home01, filled: BulkRounded.home01),
  (outline: StrokeRounded.bookOpen01, filled: BulkRounded.bookOpen01),
  (outline: StrokeRounded.comment01, filled: BulkRounded.comment01),
  (outline: StrokeRounded.jobSearch, filled: BulkRounded.jobSearch),
];

/// A solid, label-free bottom navigation bar.
///
/// Design rules:
///  - No blur / backdrop filter
///  - Filled icon when selected, outlined when not
///  - No labels
///  - Solid background that adapts to dark / light theme
///  - Active item shown with a rounded pill highlight
class BottomNav4 extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav4({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Solid colours — no transparency / blur
    final bgColor = isDark
        ? const Color(0xFF0C0B1E) // matches darkTheme cardColor from main.dart
        : const Color(
            0xFFF9F6FF,
          ); // matches lightTheme cardColor from main.dart

    final topBorderColor = isDark
        ? const Color.fromARGB(
            255,
            39,
            38,
            46,
          ) // matches darkTheme dividerColor
        : Colors.grey.shade200; // matches lightTheme dividerColor

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 55 + bottomPadding,
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPadding),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: topBorderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < _nav4Icons.length; i++)
            _NavItem(
              outlineIcon: _nav4Icons[i].outline,
              filledIcon: _nav4Icons[i].filled,
              isActive: currentIndex == i,
              isDark: isDark,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final List<List<dynamic>> outlineIcon;
  final List<List<dynamic>> filledIcon;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.outlineIcon,
    required this.filledIcon,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Active colour: use the seed colour defined in main.dart's ColorScheme
    // final activeColor = Theme.of(context).colorScheme.primary;
    final activeColor = const Color.fromARGB(255, 139, 86, 255);
    final activeColor2 = const Color.fromARGB(255, 182, 130, 255);
    // Inactive colour: subdued text colour from theme
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.35);

    // Subtle pill highlight behind the active icon
    final pillColor = activeColor.withValues(alpha: isDark ? 0.18 : 0.12);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? pillColor : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SuryaIcon(
              icon: isActive ? filledIcon : outlineIcon,
              // For filled (active) state use the primary colour; for filled
              // icons SuryaIcon supports two colours — use a gradient pair.
              color: isActive ? activeColor2 : inactiveColor,
              color2: isActive
                  ? (isDark
                        ? activeColor.withValues(alpha: 0.55)
                        : activeColor.withValues(alpha: 0.45))
                  : inactiveColor,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
