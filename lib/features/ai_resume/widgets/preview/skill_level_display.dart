import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SkillLevelDisplay extends StatelessWidget {
  final int level;
  final String type;
  final String icon;
  final Color primaryColor;

  const SkillLevelDisplay({
    super.key,
    required this.level,
    required this.type,
    required this.icon,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (level == 0 || type == 'hide') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: _buildDisplay(),
    );
  }

  Widget _buildDisplay() {
    switch (type) {
      case 'text':
        return Text(
          _getLevelText(level),
          style: TextStyle(
            fontSize: 10,
            color: primaryColor,
            fontWeight: FontWeight.w500,
          ),
        );
      case 'bar':
        return Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: level / 5,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      case 'progress':
      case 'progress-bar':
        return Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: level / 5,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      case 'dots':
      case 'circle':
        return _buildNodes(isCircle: true);
      case 'square':
        return _buildNodes(isCircle: false);
      case 'rectangle':
        return _buildNodes(isCircle: false, width: 14);
      case 'full-width':
      case 'rectangle-full':
        return _buildNodes(isCircle: false, isExpanded: true);
      case 'icon':
        return _buildIcons();
      default:
        return _buildNodes(isCircle: true);
    }
  }

  Widget _buildNodes({
    bool isCircle = true,
    double width = 8,
    bool isExpanded = false,
  }) {
    return Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      children: List.generate(5, (index) {
        final isActive = index < level;
        final node = Container(
          width: isExpanded ? null : width,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? primaryColor
                : primaryColor.withValues(alpha: 0.2),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(1),
          ),
        );

        if (isExpanded) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 4 ? 0 : 4),
              child: node,
            ),
          );
        }

        return Padding(padding: const EdgeInsets.only(right: 4), child: node);
      }),
    );
  }

  Widget _buildIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isActive = index < level;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            _getIconData(icon),
            size: 12,
            color: isActive
                ? primaryColor
                : primaryColor.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }

  String _getLevelText(int level) {
    return switch (level) {
      1 => 'Novice',
      2 => 'Beginner',
      3 => 'Intermediate',
      4 => 'Advanced',
      5 => 'Expert',
      _ => '',
    };
  }

  IconData _getIconData(String name) {
    // Simple mapping for demonstration, real app might need a more robust icon mapping
    switch (name.toLowerCase()) {
      case 'star':
        return LucideIcons.star;
      case 'circle':
        return LucideIcons.circle;
      case 'square':
        return LucideIcons.square;
      case 'heart':
        return LucideIcons.heart;
      default:
        return LucideIcons.circle;
    }
  }
}
