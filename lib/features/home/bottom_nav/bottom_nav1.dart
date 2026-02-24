import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

final navRoutes = [
  (route: '/', icon: HugeIcons.strokeRoundedHome01, label: 'Home'),
  (
    route: '/courses',
    icon: HugeIcons.strokeRoundedBookOpen01,
    label: 'Courses',
  ),
  (
    route: '/messages',
    icon: HugeIcons.strokeRoundedComment01,
    label: 'Messages',
  ),
  (route: '/jobs', icon: HugeIcons.strokeRoundedJobSearch, label: 'Jobs'),
];

class BottomNav1 extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav1({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? Colors.black.withValues(alpha: 0.8)
        : Theme.of(context).cardColor.withValues(alpha: 0.9);
    final double blur = isDark ? 30 : 20;
    final double bottomPadding = max(
      0,
      MediaQuery.of(context).padding.bottom - 10,
    );
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: 70 + bottomPadding,
          padding: EdgeInsets.only(left: 24, right: 24, bottom: bottomPadding),
          decoration: BoxDecoration(
            color: color,
            border: Border(
              top: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < navRoutes.length; i++)
                _buildNavItem(
                  context,
                  navRoutes[i].icon,
                  navRoutes[i].label,
                  currentIndex == i,
                  () {
                    onTap(i);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    dynamic icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    final activeColor = Theme.of(context).primaryColor;
    final inactiveColor = Theme.of(context).unselectedWidgetColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? activeColor : inactiveColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
