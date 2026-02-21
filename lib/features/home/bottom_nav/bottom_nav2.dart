import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class BottomNav2 extends StatelessWidget {
  const BottomNav2({super.key});

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    // final color = isDark
    //     ? Colors.black.withValues(alpha: 0.8)
    //     : const Color.fromARGB(255, 230, 230, 230).withValues(alpha: 0.8);
    // final double blur = isDark ? 30 : 20;

    return BottomAppBar(
      color: Theme.of(context).cardColor,
      elevation: 10,
      notchMargin: 12.0, // Increased margin to match padding
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: const _SharpNotchedRectangle(),
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, HugeIcons.strokeRoundedHome01, "Home", true),
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
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.65, 0)
      ..lineTo(size.width * 0.95, size.height)
      ..lineTo(size.width * 0.05, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
