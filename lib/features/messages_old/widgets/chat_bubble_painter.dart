import 'package:flutter/material.dart';

class ChatBubblePainter extends CustomPainter {
  final Color color;
  final bool isMe;
  final bool showTail;

  ChatBubblePainter({
    required this.color,
    required this.isMe,
    this.showTail = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const radius = 20.0;
    const tailWidth = 10.0;

    if (isMe) {
      // Outgoing bubble (Right side)
      path.addRRect(RRect.fromLTRBAndCorners(
        0,
        0,
        size.width,
        size.height,
        topLeft: const Radius.circular(radius),
        topRight: const Radius.circular(radius),
        bottomLeft: const Radius.circular(radius),
        bottomRight: showTail ? Radius.zero : const Radius.circular(radius),
      ));

      if (showTail) {
        path.moveTo(size.width, size.height - 15);
        path.lineTo(size.width + tailWidth, size.height);
        path.lineTo(size.width - 5, size.height);
        path.close();
      }
    } else {
      // Incoming bubble (Left side)
      path.addRRect(RRect.fromLTRBAndCorners(
        0,
        0,
        size.width,
        size.height,
        topLeft: const Radius.circular(radius),
        topRight: const Radius.circular(radius),
        bottomLeft: showTail ? Radius.zero : const Radius.circular(radius),
        bottomRight: const Radius.circular(radius),
      ));

      if (showTail) {
        path.moveTo(0, size.height - 15);
        path.lineTo(-tailWidth, size.height);
        path.lineTo(5, size.height);
        path.close();
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
