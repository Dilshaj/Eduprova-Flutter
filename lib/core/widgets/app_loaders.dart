import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImageLoader extends StatelessWidget {
  const ShimmerImageLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ColoredBox(color: Colors.white),
    );
  }
}

class TripleDotLoader extends StatelessWidget {
  final Color color;
  final double size;

  const TripleDotLoader({
    super.key,
    this.color = Colors.white,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(color: color, size: size);
  }
}
