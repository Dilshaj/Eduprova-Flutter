import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:suryaicons/bulk_rounded.dart';
import 'package:suryaicons/stroke_rounded.dart';
import 'package:suryaicons/suryaicons.dart';

class BottomNav3 extends StatelessWidget {
  const BottomNav3({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? Colors.black.withValues(alpha: 0.8)
        : const Color.fromARGB(255, 230, 230, 230).withValues(alpha: 0.8);
    final double blur = isDark ? 30 : 20;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: 90,
          padding: EdgeInsets.only(
            top: 8,
            left: 24,
            right: 24,
            bottom: bottomPadding,
          ),
          decoration: BoxDecoration(
            color: color,
            border: const Border(top: BorderSide(color: Colors.white24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                // HugeIcons.strokeRoundedHome01,
                StrokIcon(StrokeRounded.home01),
                ThemedIcon(BulkRounded.home01),
                "Home",
                true,
              ),
              _buildNavItem(
                context,
                StrokIcon(StrokeRounded.bookOpen01),
                ThemedIcon(BulkRounded.bookOpen01),
                "Courses",
                false,
              ),
              _buildNavItem(
                context,

                StrokIcon(StrokeRounded.add01),
                ThemedIcon(BulkRounded.add01),
                "Add",
                false,
              ),
              _buildNavItem(
                context,
                StrokIcon(StrokeRounded.comment01),
                ThemedIcon(BulkRounded.comment01),
                "Messages",
                false,
              ),
              _buildNavItem(
                context,
                StrokIcon(StrokeRounded.jobSearch),
                ThemedIcon(BulkRounded.jobSearch),
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
    Widget icon,
    Widget activeIcon,
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
                // SuryaIcon(
                //   icon: icon,
                //   color: isActive ? activeColor : inactiveColor,
                //   size: 26,
                // ),
                isActive ? activeIcon : icon,
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

class StrokIcon extends StatelessWidget {
  final List<List<dynamic>> icon;
  const StrokIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return SuryaIcon(
      icon: icon,
      //  color: const Color.fromARGB(255, 49, 76, 255)
      color: const Color.fromARGB(255, 170, 24, 255),
    );
  }
}

class ThemedIcon extends StatelessWidget {
  final List<List<dynamic>> icon;
  const ThemedIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return SuryaIcon(
      icon: icon,
      color: const Color.fromARGB(255, 112, 93, 255),
      color2: const Color.fromARGB(255, 173, 9, 255),
      opacity: 0.5,
    );
  }
}
