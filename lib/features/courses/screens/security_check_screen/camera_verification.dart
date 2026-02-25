import 'package:flutter/material.dart';
import 'dart:async';
import 'continue_button.dart';

class CameraVerification extends StatefulWidget {
  final bool cameraPermission;
  final VoidCallback onRequestPermission;
  final FaceStatus faceStatus;
  final void Function(FaceStatus status, [String? snapshot]) onFaceStatusChange;
  final bool cameraActive;
  final VoidCallback onStartCamera;
  final bool locked;
  final String? capturedFaceUri;

  const CameraVerification({
    super.key,
    required this.cameraPermission,
    required this.onRequestPermission,
    required this.faceStatus,
    required this.onFaceStatusChange,
    required this.cameraActive,
    required this.onStartCamera,
    required this.locked,
    required this.capturedFaceUri,
  });

  @override
  State<CameraVerification> createState() => _CameraVerificationState();
}

class _CameraVerificationState extends State<CameraVerification>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  Timer? _mockTimer;

  // Constants
  static const double circleSize = 240;
  static const double innerSize = 228;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.cameraActive && !widget.locked) {
      _startMockDetection();
    }
  }

  @override
  void didUpdateWidget(covariant CameraVerification oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.cameraActive && widget.cameraActive && !widget.locked) {
      _startMockDetection();
    }

    if (widget.faceStatus == FaceStatus.verified || widget.locked) {
      _ringController.duration = const Duration(milliseconds: 900);
      _ringController.repeat(reverse: true);
    } else if (widget.faceStatus == FaceStatus.single) {
      _ringController.duration = const Duration(milliseconds: 600);
      _ringController.repeat(reverse: true);
    } else {
      _ringController.stop();
      _ringController.value = 0;
    }
  }

  void _startMockDetection() {
    _mockTimer?.cancel();
    // Simulate finding a single face after 1.5 seconds
    _mockTimer = Timer(const Duration(milliseconds: 1500), () {
      widget.onFaceStatusChange(FaceStatus.single);
      // Simulate verifying after another 3 seconds (as requested in exact requirements)
      _mockTimer = Timer(const Duration(seconds: 3), () {
        widget.onFaceStatusChange(FaceStatus.verified, 'mock_image_uri');
      });
    });
  }

  @override
  void dispose() {
    _ringController.dispose();
    _mockTimer?.cancel();
    super.dispose();
  }

  Color get _ringColor {
    if (widget.locked ||
        widget.faceStatus == FaceStatus.verified ||
        widget.faceStatus == FaceStatus.single) {
      return const Color(0xFF22C55E);
    } else if (!widget.locked && widget.faceStatus == FaceStatus.multiple) {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFFD1D5DB);
  }

  Map<String, dynamic> get _statusData {
    if (widget.locked || widget.faceStatus == FaceStatus.verified) {
      return {
        'text': 'Face verified',
        'color': const Color(0xFF22C55E),
        'icon': Icons.check_circle,
      };
    }
    switch (widget.faceStatus) {
      case FaceStatus.none:
        return {
          'text': 'No face detected',
          'color': const Color(0xFF6B7280),
          'icon': Icons.person_outline,
        };
      case FaceStatus.multiple:
        return {
          'text': 'Multiple faces detected — only one allowed',
          'color': const Color(0xFFEF4444),
          'icon': Icons.people_outline,
        };
      case FaceStatus.single:
        return {
          'text': 'Single user detected',
          'color': const Color(0xFF22C55E),
          'icon': Icons.check_circle,
        };
      default:
        return {
          'text': 'No face detected',
          'color': const Color(0xFF6B7280),
          'icon': Icons.person_outline,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locked) {
      return _buildLocked();
    }
    if (!widget.cameraActive) {
      return _buildIdle();
    }
    return _buildActive();
  }

  Widget _buildLocked() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            width: circleSize + 20,
            height: circleSize + 20,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    final scale = 1.0 + (_ringController.value * 0.05);
                    final opacity = 0.85 - (_ringController.value * 0.35);
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: circleSize + 10,
                          height: circleSize + 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _ringColor, width: 3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF111827),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: widget.capturedFaceUri != null
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD1D5DB), // Mock Image placeholder
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle,
                          size: 48,
                          color: Color(0xFF22C55E),
                        ),
                ),
              ],
            ),
          ),
          const Text(
            'Face verified',
            style: TextStyle(
              color: Color(0xFF22C55E),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdle() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            width: circleSize + 20,
            height: circleSize + 20,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.videocam_outlined,
                size: 42,
                color: Color(0xFFD1D5DB),
              ),
            ),
          ),
          InkWell(
            onTap: !widget.cameraPermission
                ? widget.onRequestPermission
                : widget.onStartCamera,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF1D4ED8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        !widget.cameraPermission
                            ? 'Grant Permission'
                            : 'Start Camera',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActive() {
    final status = _statusData;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            width: circleSize + 20,
            height: circleSize + 20,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    final scale = 1.0 + (_ringController.value * 0.05);
                    final opacity = 0.85 - (_ringController.value * 0.35);
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: circleSize + 10,
                          height: circleSize + 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _ringColor, width: 3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF111827),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: widget.capturedFaceUri != null
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: const Color(0xFF1F2937),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.camera_front,
                            color: Color(0xFF4B5563),
                            size: 48,
                          ), // Mock Native live feed
                        ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(status['icon'], size: 14, color: status['color']),
              const SizedBox(width: 5),
              Text(
                status['text'],
                style: TextStyle(
                  color: status['color'],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
