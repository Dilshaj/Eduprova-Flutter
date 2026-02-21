import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class BottomNav2 extends StatelessWidget {
  const BottomNav2({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? Colors.black.withValues(alpha: 0.8)
        : const Color.fromARGB(255, 230, 230, 230).withValues(alpha: 0.75);
    final double blur = isDark ? 30 : 20;

    return ClipPath(
      clipper: const _NotchedClipper(_SharpNotchedRectangle()),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: BottomAppBar(
          color: color,
          elevation: 0.5,
          notchMargin: 12.0, // Increased margin to match padding
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          height: 70,
          shape: const _SharpNotchedRectangle(),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  HugeIcons.strokeRoundedHome01,
                  "Home",
                  true,
                ),
                _buildNavItem(
                  context,
                  HugeIcons.strokeRoundedBookOpen01,
                  "Courses",
                  false,
                ),
                const SizedBox(width: 48), // gap for FAB
                _buildNavItem(
                  context,
                  HugeIcons.strokeRoundedComment01,
                  "Messages",
                  false,
                ),
                _buildNavItem(
                  context,
                  HugeIcons.strokeRoundedJobSearch,
                  "Jobs",
                  false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    dynamic icon,
    String label,
    bool isActive,
  ) {
    final activeColor = const Color(0xFF4A8BFF);
    final inactiveColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ??
        Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (isActive)
              Positioned.fill(
                child: CustomPaint(painter: _TorchPainter(activeColor)),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? activeColor : inactiveColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TorchPainter extends CustomPainter {
  final Color color;
  _TorchPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
        stops: const [0.1, 0.55],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // final path = Path()
    //   ..moveTo(size.width * 0.3, size.height - 5) // bottom left point
    //   ..lineTo(size.width * 0.7, size.height - 5) // bottom right point
    //   ..lineTo(size.width, size.height * 0) // top right point
    //   ..lineTo(0, size.height * 0) // top left point
    //   ..close();

    final radius = 10.0;

    final path = Path()
      ..moveTo(size.width * 0.25 + radius, size.height - 5)
      // bottom line
      ..lineTo(size.width * 0.75 - radius, size.height - 5)
      // bottom-right corner radius
      ..arcToPoint(
        Offset(size.width * 0.75, size.height - 5 - radius),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      // right side to top
      ..lineTo(size.width, 0)
      // top line
      ..lineTo(0, 0)
      // left side down
      ..lineTo(size.width * 0.25, size.height - 5 - radius)
      // bottom-left corner radius
      ..arcToPoint(
        Offset(size.width * 0.25 + radius, size.height - 5),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotchedClipper extends CustomClipper<Path> {
  final NotchedShape shape;
  const _NotchedClipper(this.shape);

  @override
  Path getClip(Size size) {
    // We assume the host is the full size of the bottom app bar footprint
    // and we roughly estimate the FAB placement based on standard heights.
    // BottomAppBar itself internally computes the actual rects, but to clip it correctly
    // for the BackdropFilter we must provide the hole.
    final host = Rect.fromLTWH(0, 0, size.width, size.height);
    // Standard floating action button size + margins
    final guest = Rect.fromCenter(
      center: Offset(size.width / 2.0, 20.0), // match our transform offset!
      width: 56.0 + 24.0, // FAB width (56) + total margin around it (12*2)
      height: 56.0 + 24.0,
    );
    return shape.getOuterPath(host, guest);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class _SharpNotchedRectangle extends NotchedShape {
  const _SharpNotchedRectangle();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRRect(
        RRect.fromRectAndCorners(
          host,
          topLeft: const Radius.circular(24.0),
          topRight: const Radius.circular(24.0),
        ),
      );
    }

    // We want the notch to plunge deep into the bar and curve fully around the FAB.
    // Standard Flutter `CircularNotchedRectangle` actually curves away, making the gap shallow.
    // We compute a custom U-shaped valley.
    // The guest (FAB) center is natively considered `host.top` when `FloatingActionButtonLocation.centerDocked` is applied.
    // We visually shifted the FAB down inside HomeScreen using a transform.
    // Now we must offset our hole's geometry down by that same 20 pixels to keep it wrapped perfectly around the button.
    final double notchRadius = guest.width / 2.0;
    const double smoothRadius = 14.0;
    final double buttonCenterYOffset =
        host.top + 16.0; // Pushed down by exactly the transform offset amount.

    return Path()
      ..moveTo(host.left, host.top + 24.0)
      ..arcToPoint(
        Offset(host.left + 24.0, host.top),
        radius: const Radius.circular(24.0),
        clockwise: true,
      )
      ..lineTo(guest.center.dx - notchRadius - smoothRadius, host.top)
      ..arcToPoint(
        Offset(guest.center.dx - notchRadius, buttonCenterYOffset),
        radius: const Radius.circular(smoothRadius),
        clockwise: true,
      )
      // Carve deeply around the pushed-down button center
      ..arcToPoint(
        Offset(guest.center.dx + notchRadius, buttonCenterYOffset),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(guest.center.dx + notchRadius + smoothRadius, host.top),
        radius: const Radius.circular(smoothRadius),
        clockwise: true,
      )
      ..lineTo(host.right - 24.0, host.top)
      ..arcToPoint(
        Offset(host.right, host.top + 24.0),
        radius: const Radius.circular(24.0),
        clockwise: true,
      )
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}
