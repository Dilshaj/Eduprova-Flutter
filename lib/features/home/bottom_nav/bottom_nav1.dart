import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

final navRoutes = [
  (route: '/chats', icon: HugeIcons.strokeRoundedComment01, label: 'Chats', badge: 7, isAvatar: false),
  (route: '/contacts', icon: HugeIcons.strokeRoundedUserGroup, label: 'Contacts', badge: 0, isAvatar: false),
  (route: '/settings', icon: HugeIcons.strokeRoundedSettings01, label: 'Settings', badge: 0, isAvatar: false),
  (route: '/profile', icon: null, label: 'Profile', badge: 0, isAvatar: true),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isDark
        ? const Color(0xFF1C1C1D).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.9);

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : const Color(0xFF000000).withValues(alpha: 0.08);

    final double bottomMargin = max(
      16,
      MediaQuery.paddingOf(context).bottom + 8,
    );

    return Align(
      alignment: .bottomCenter,
      child: Padding(
        padding: .only(left: 16, right: 16, bottom: bottomMargin),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: .circular(36),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: .circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 72,
                padding: .symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: .circular(36),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.03),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    for (var (i, item) in navRoutes.indexed)
                      _buildNavItem(
                        context: context,
                        icon: item.icon,
                        label: item.label,
                        badge: item.badge,
                        isAvatar: item.isAvatar,
                        isActive: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    dynamic icon,
    required String label,
    required int badge,
    required bool isAvatar,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFF3390EC) : const Color(0xFF007AFF);
    final inactiveColor =
        isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5);

    final itemColor = isActive ? activeColor : inactiveColor;
    final activeBgColor = activeColor.withValues(alpha: 0.12);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: .symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? activeBgColor : Colors.transparent,
              borderRadius: .circular(24),
            ),
            child: Column(
              mainAxisSize: .min,
              children: [
                Stack(
                  clipBehavior: .none,
                  children: [
                    if (isAvatar)
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: itemColor,
                            width: isActive ? 2 : 0,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      HugeIcon(
                        icon: icon,
                        color: itemColor,
                        size: 26,
                      ),
                    if (badge > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: .all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3390EC),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            badge.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              height: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 11,
                    color: itemColor,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
