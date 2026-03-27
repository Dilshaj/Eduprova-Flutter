import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChatDoodlePainter extends CustomPainter {
  final Color color;

  ChatDoodlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final random = math.Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final type = random.nextInt(4);

      switch (type) {
        case 0: // Circle
          canvas.drawCircle(Offset(x, y), 10 + random.nextDouble() * 10, paint);
          break;
        case 1: // Wave
          final path = Path();
          path.moveTo(x, y);
          path.quadraticBezierTo(x + 10, y - 10, x + 20, y);
          path.quadraticBezierTo(x + 30, y + 10, x + 40, y);
          canvas.drawPath(path, paint);
          break;
        case 2: // Triangle/Star bit
          final path = Path();
          path.moveTo(x, y);
          path.lineTo(x + 10, y + 15);
          path.lineTo(x - 5, y + 15);
          path.close();
          canvas.drawPath(path, paint);
          break;
        case 3: // Heart-ish
          final path = Path();
          path.moveTo(x, y);
          path.cubicTo(x - 10, y - 10, x - 15, y + 5, x, y + 15);
          path.cubicTo(x + 15, y + 5, x + 10, y - 10, x, y);
          canvas.drawPath(path, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
