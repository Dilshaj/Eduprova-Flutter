import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

final navItems = [
  (
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_filled,
    type: 0,
  ),
  (
    label: 'Courses',
    icon: HugeIcons.strokeRoundedBookOpen01,
    activeIcon: HugeIcons.strokeRoundedBookOpen01,
    type: 0,
  ),
  (label: 'Create Post', icon: Icons.add, activeIcon: Icons.add, type: 1),
  (
    label: 'Messages',
    icon: HugeIcons.strokeRoundedComment01,
    activeIcon: HugeIcons.strokeRoundedComment01,
    type: 0,
  ),
  (label: 'Profile', icon: null, activeIcon: null, type: 2),
];

class BottomNav3 extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNav3({super.key, this.currentIndex = 0, this.onTap});

  @override
  State<BottomNav3> createState() => _BottomNav3State();
}

class _BottomNav3State extends State<BottomNav3> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(BottomNav3 oldWidget) {
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onTap(int index) {
    if (widget.onTap != null) {
      widget.onTap!(index);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isDark ? const Color(0xFF141414) : Colors.white;

    final double bottomMargin = 0.0;

    return Align(
      alignment: .bottomCenter,
      child: Padding(
        padding: .only(left: 8, right: 8, bottom: bottomMargin),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: .circular(45),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: .spaceEvenly,
            children: [
              for (final (i, item) in navItems.indexed)
                _buildNavItem(
                  context: context,
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  type: item.type,
                  isActive: _currentIndex == i,
                  onTap: () => _onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required dynamic icon,
    required dynamic activeIcon,
    required String label,
    required int type,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark
        ? const Color(0xFF4A90E2)
        : const Color(0xFF1877F2);
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.6);

    final currentColor = isActive ? activeColor : inactiveColor;
    final currentIcon = isActive ? activeIcon : icon;

    final pillBgColor = isActive
        ? activeColor.withValues(alpha: 0.12)
        : Colors.transparent;

    Widget iconWidget;

    if (type == 2) {
      iconWidget = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? activeColor : Colors.transparent,
            width: isActive ? 2 : 0,
          ),
          image: const DecorationImage(
            image: NetworkImage('https://i.pravatar.cc/150?img=47'),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (type == 1) {
      final btnBg = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.06);

      iconWidget = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.15) : btnBg,
          borderRadius: .circular(10),
        ),
        child: Icon(
          currentIcon,
          color: isActive ? activeColor : inactiveColor,
          size: 20,
        ),
      );
    } else {
      if (currentIcon is IconData) {
        iconWidget = Icon(currentIcon, color: currentColor, size: 24);
      } else {
        iconWidget = HugeIcon(icon: currentIcon, color: currentColor, size: 24);
      }
    }

    final hasActivePill = isActive && type != 1;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: .symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: hasActivePill ? pillBgColor : Colors.transparent,
              borderRadius: .circular(30),
            ),
            child: Column(
              mainAxisSize: .min,
              children: [
                iconWidget,
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 10,
                    color: currentColor,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
