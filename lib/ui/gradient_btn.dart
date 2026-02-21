import 'package:flutter/material.dart';

class GradientBtn extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double fontSize;
  final double borderRadius;
  final EdgeInsets? padding;
  final double elevation;

  const GradientBtn({
    required this.title,
    required this.onTap,
    this.width,
    this.height,
    this.fontSize = 16,
    this.borderRadius = 12,
    this.padding,
    this.elevation = 6,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: elevation,
      shadowColor: Colors.black.withOpacity(0.25),
      child: Ink(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0066FF), Color(0xFFF15EC9)],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Padding(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
