import 'dart:math' as math;
import 'package:flutter/material.dart';

class ResumeFlippingWidget extends StatefulWidget {
  const ResumeFlippingWidget({super.key});

  @override
  State<ResumeFlippingWidget> createState() => _ResumeFlippingWidgetState();
}

class _ResumeFlippingWidgetState extends State<ResumeFlippingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _images = [
    'assets/resume-landing-page/resume1.jpg',
    'assets/resume-landing-page/resume2.jpg',
    'assets/resume-landing-page/resume3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const .new(
        seconds: 15,
      ), // 5 seconds per card (3.5s wait + 1.5s flip)
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(alignment: .center, children: _buildCards());
        },
      ),
    );
  }

  List<Widget> _buildCards() {
    double globalT = _controller.value;
    int stage = (globalT * 3).floor() % 3;
    double stageT = (globalT * 3) % 1.0;

    double tFlip = 0.0;
    if (stageT > 0.7) {
      // 3.5s pause + 1.5s flip
      tFlip = ((stageT - 0.7) / 0.3).clamp(0.0, 1.0);
      tFlip = Curves.easeInOut.transform(tFlip);
    }

    int cFront = stage;
    int cLeft = (stage + 1) % 3;
    int cRight = (stage + 2) % 3;

    final cardFront = _buildCard(cFront, _getFrontToRightBack(tFlip));
    final cardLeft = _buildCard(cLeft, _getLeftBackToFront(tFlip));
    final cardRight = _buildCard(cRight, _getRightToLeftBack(tFlip));

    if (tFlip < 0.5) {
      return [cardLeft, cardRight, cardFront];
    } else {
      return [cardRight, cardFront, cardLeft];
    }
  }

  _CardState _getFrontToRightBack(double t) {
    // P0 (Front) -> P2 (RightBack)
    double x = lerp(0, 16, t);
    double rot = lerp(0, 0.18, t);
    double scale = lerp(1.0, 0.85, t);
    double opacity = lerp(1.0, 0.7, t);
    // Raise card so bottom corners align with front card:
    // rotation around bottomCenter dips corners by (halfWidth*scale)*sin(|rot|)
    double y = -(100 * scale * math.sin(rot.abs()));
    return _CardState(
      x: x,
      y: y,
      scale: scale,
      opacity: opacity,
      rotation: rot,
    );
  }

  _CardState _getRightToLeftBack(double t) {
    // P2 (RightBack) -> P1 (LeftBack)
    double x = lerp(16, -16, t);
    double rot = lerp(0.18, -0.18, t);
    double scale = 0.85;
    double opacity = 0.7;
    double y = -(100 * scale * math.sin(rot.abs()));
    return _CardState(
      x: x,
      y: y,
      scale: scale,
      opacity: opacity,
      rotation: rot,
    );
  }

  _CardState _getLeftBackToFront(double t) {
    // P1 (LeftBack) -> P0 (Front) (The FLIP)
    double x = -16;
    double scale = 0.85;
    double opacity = 0.7;
    double rotation = -0.18;

    if (t < 0.45) {
      double tt = (t / 0.45).clamp(0.0, 1.0);
      x = lerp(-16, -180, Curves.easeOut.transform(tt));
      rotation = lerp(-0.18, -0.25, tt);
    } else {
      double tt = ((t - 0.45) / 0.55).clamp(0.0, 1.0);
      x = lerp(-180, 0, Curves.easeIn.transform(tt));
      scale = lerp(0.85, 1.0, tt);
      opacity = lerp(0.7, 1.0, tt);
      rotation = lerp(-0.25, 0, tt);
    }

    // Raise card so bottom corners align with front card
    double y = -(100 * scale * math.sin(rotation.abs()));
    return _CardState(
      x: x,
      y: y,
      scale: scale,
      opacity: opacity,
      rotation: rotation,
    );
  }

  double lerp(double a, double b, double t) => a + (b - a) * t;

  Widget _buildCard(int index, _CardState state) {
    return Transform.translate(
      offset: .new(state.x, state.y),
      child: Transform.rotate(
        angle: state.rotation,
        alignment: .bottomCenter,
        child: Transform.scale(
          scale: state.scale,
          alignment: .bottomCenter,
          child: Opacity(
            opacity: state.opacity.clamp(0.0, 1.0),
            child: Container(
              width: 200,
              // height: 280,
              decoration: BoxDecoration(
                borderRadius: .circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: state.scale > 0.95 ? 0.12 : 0.04,
                    ),
                    blurRadius: state.scale > 0.95 ? 20 : 10,
                    offset: .new(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: .circular(16),
                child: Image.asset(_images[index], fit: .cover),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardState {
  final double x, y, scale, opacity, rotation;
  _CardState({
    required this.x,
    required this.y,
    required this.scale,
    required this.opacity,
    required this.rotation,
  });
}
