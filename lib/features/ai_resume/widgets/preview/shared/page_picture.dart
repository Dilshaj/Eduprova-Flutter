import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';

class PagePicture extends StatelessWidget {
  final Picture picture;
  final String? name;

  const PagePicture({super.key, required this.picture, this.name});

  @override
  Widget build(BuildContext context) {
    if (picture.hidden || picture.url.isEmpty) return const SizedBox.shrink();

    final size = picture.size;
    final aspectRatio = picture.aspectRatio;

    return Transform.rotate(
      angle: picture.rotation * (3.14159 / 180),
      child: Container(
        width: size,
        height: size / aspectRatio,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(picture.borderRadius),
          boxShadow: picture.shadowWidth > 0
              ? [
                  BoxShadow(
                    color: _parseColor(
                      picture.shadowColor,
                      Colors.black.withValues(alpha: 0.1),
                    ),
                    blurRadius: picture.shadowWidth,
                  ),
                ]
              : null,
          border: picture.borderWidth > 0
              ? Border.all(
                  color: _parseColor(picture.borderColor, Colors.black),
                  width: picture.borderWidth,
                )
              : null,
          image: DecorationImage(
            image: picture.url.startsWith('http')
                ? NetworkImage(picture.url)
                : FileImage(File(picture.url)) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex, Color fallback) {
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
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
