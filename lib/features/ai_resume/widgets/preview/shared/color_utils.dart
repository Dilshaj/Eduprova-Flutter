import 'package:flutter/material.dart';

class ColorUtils {
  static Color parseColor(String hex, Color fallback) {
    try {
      if (hex.startsWith('rgba')) {
        final values = hex
            .replaceAll('rgba(', '')
            .replaceAll(')', '')
            .split(',')
            .map((e) => e.trim())
            .toList();
        if (values.length >= 3) {
          int r = int.parse(values[0]);
          int g = int.parse(values[1]);
          int b = int.parse(values[2]);
          double a = values.length == 4 ? double.parse(values[3]) : 1.0;
          return Color.fromARGB((a * 255).toInt(), r, g, b);
        }
      }
      String cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      if (cleanHex.length == 8) return Color(int.parse(cleanHex, radix: 16));
      return fallback;
    } catch (_) {
      return fallback;
    }
  }
}
