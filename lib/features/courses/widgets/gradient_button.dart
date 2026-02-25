import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  final double? width;
  final double height;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? margin;
  final List<Color>? colors;

  const GradientButton({
    super.key,
    required this.title,
    required this.onPress,
    this.width,
    this.height = 48,
    this.textStyle,
    this.margin,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: colors ?? const [Color(0xFF0066FF), Color(0xFFE056FD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPress,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Text(
              title,
              style:
                  textStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
