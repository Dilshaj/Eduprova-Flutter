import 'package:eduprova/constants.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:eduprova/core/widgets/app_loaders.dart';

class GradientBtn extends StatelessWidget {
  final String? title;
  final Widget? child;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double fontSize;
  final double borderRadius;
  final EdgeInsets? padding;
  final double elevation;
  final bool isLoading;
  final Alignment? alignment;

  const GradientBtn({
    this.title,
    this.child,
    required this.onTap,
    this.width,
    this.height,
    this.fontSize = 16,
    this.borderRadius = 10,
    this.padding,
    this.elevation = 6,
    this.isLoading = false,
    this.alignment,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = context.design;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: elevation,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: Ink(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          // gradient: const LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [Color(0xFF0066FF), Color(0xFFF15EC9)],
          // ),
          gradient: themeExt.buyNowGradient,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: isLoading ? null : onTap,
          splashColor: const Color.fromARGB(59, 0, 64, 255),
          highlightColor: Colors.white10,
          child: Padding(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Align(
              alignment: alignment ?? Alignment.center,
              child: isLoading
                  ? const TripleDotLoader()
                  : child ??
                        Text(
                          title!,
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

  // Widget _buildAddButton(bool isDark) {
  //   return GestureDetector(
  //     onTap: _pickMoreImages,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 16),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.grey.shade300, width: 1),
  //         color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
  //       ),
  //       // Simple faux-dashed look by just using a regular outline but styled gently.
  //       // The dotted_decoration package is in pubspec, we can use it!
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.add, color: Colors.grey.shade600, size: 20),
  //           const SizedBox(width: 8),
  //           Text(
  //             'Add',
  //             style: TextStyle(
  //               color: Colors.grey.shade600,
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }