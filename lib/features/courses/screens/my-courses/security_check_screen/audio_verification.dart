import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AudioVerification extends StatefulWidget {
  final bool isActive;
  final bool audioVerified;
  final VoidCallback onAudioVerified;
  final double audioLevel;
  final ValueChanged<double> onAudioLevelChange;

  const AudioVerification({
    super.key,
    required this.isActive,
    required this.audioVerified,
    required this.onAudioVerified,
    required this.audioLevel,
    required this.onAudioLevelChange,
  });

  @override
  State<AudioVerification> createState() => _AudioVerificationState();
}

class _AudioVerificationState extends State<AudioVerification>
    with SingleTickerProviderStateMixin {
  late AnimationController _micController;
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.isActive && !widget.audioVerified) {
      _startMicAnimation();
      _startMockMic();
    }
  }

  @override
  void didUpdateWidget(covariant AudioVerification oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive && !widget.audioVerified) {
      _startMicAnimation();
      _startMockMic();
    }
    if (!oldWidget.audioVerified && widget.audioVerified) {
      _startVerifiedAnimation();
    }
  }

  void _startMockMic() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (widget.audioVerified) {
        timer.cancel();
        return;
      }
      // Mocking audio levels like someone talking
      final level = Random().nextDouble();
      widget.onAudioLevelChange(level);

      // Auto verify after a few levels over threshold
      if (level > 0.8) {
        timer.cancel();
        widget.onAudioVerified();
      }
    });
  }

  @override
  void dispose() {
    _micController.dispose();
    _mockTimer?.cancel();
    super.dispose();
  }

  void _startMicAnimation() {
    _micController.repeat(reverse: true);
  }

  void _startVerifiedAnimation() {
    _micController.duration = const Duration(milliseconds: 500);
    _micController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Mic Wrap
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedBuilder(
              animation: _micController,
              builder: (context, child) {
                final scale = widget.audioVerified
                    ? 1.0 + (_micController.value * 0.08)
                    : (widget.isActive
                          ? 0.95 + (_micController.value * 0.17)
                          : 1.0);

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.audioVerified
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFF3F4F6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      widget.audioVerified ? Icons.mic : Icons.mic_none,
                      size: 28,
                      color: widget.audioVerified
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                );
              },
            ),
          ),

          // Wave Row
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(16, (i) {
                  final center = 16 / 2;
                  final dist = (i - center).abs() / center;

                  double factor;
                  if (widget.audioVerified) {
                    factor = 0.6 + sin((i / 16) * pi) * 0.4;
                  } else {
                    factor =
                        widget.audioLevel *
                        (1 - dist * 0.5) *
                        (0.4 + Random().nextDouble() * 0.6);
                  }

                  final h = factor * 28 + 3;
                  final barHeight = max(4.0, min(28.0, h)).toDouble();

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 3.5,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: widget.audioVerified
                          ? const Color(0xFF22C55E)
                          : widget.audioLevel > 0.03
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Status text
          Text(
            widget.audioVerified
                ? 'Audio verified'
                : 'Speak to verify microphone...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.audioVerified
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
