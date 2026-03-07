import 'package:flutter/material.dart';

class PageLink extends StatelessWidget {
  final String url;
  final String label;
  final IconData? icon;
  final TextStyle? style;
  final Color? iconColor;

  const PageLink({
    super.key,
    required this.url,
    required this.label,
    this.icon,
    this.style,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty && url.isEmpty) return const SizedBox.shrink();

    final displayText = label.isNotEmpty ? label : url;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: (style?.fontSize ?? 10) * 1.2,
            color: iconColor ?? style?.color?.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            displayText,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
