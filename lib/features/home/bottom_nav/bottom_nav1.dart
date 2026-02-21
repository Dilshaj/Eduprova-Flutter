import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class BottomNav1 extends StatelessWidget {
  const BottomNav1({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? Colors.black.withValues(alpha: 0.8)
        : const Color.fromARGB(255, 230, 230, 230).withValues(alpha: 0.8);
    final double blur = isDark ? 30 : 20;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: color,
            border: const Border(top: BorderSide(color: Colors.white24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                HugeIcons.strokeRoundedHome01,
                "Home",
                true,
              ),
              _buildNavItem(
                context,
                HugeIcons.strokeRoundedBookOpen01,
                "Courses",
                false,
              ),
              _buildNavItem(
                context,
                HugeIcons.strokeRoundedAdd01,
                "Add",
                false,
              ),
              _buildNavItem(
                context,
                HugeIcons.strokeRoundedComment01,
                "Messages",
                false,
              ),
              _buildNavItem(
                context,
                HugeIcons.strokeRoundedJobSearch,
                "Jobs",
                false,
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
  ) {
    final activeColor = const Color(0xFF4A8BFF);
    final inactiveColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ??
        Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () {},
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
