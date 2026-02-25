import 'package:flutter/material.dart';

enum FaceStatus { none, multiple, partial, stabilising, verified, single }

class ContinueButton extends StatelessWidget {
  final String step; // 'camera' or 'audio'
  final FaceStatus faceStatus;
  final bool cameraLocked;
  final bool audioVerified;
  final VoidCallback onNext;
  final VoidCallback onFinish;
  final double paddingBottom;

  const ContinueButton({
    super.key,
    required this.step,
    required this.faceStatus,
    required this.cameraLocked,
    required this.audioVerified,
    required this.onNext,
    required this.onFinish,
    this.paddingBottom = 16,
  });

  @override
  Widget build(BuildContext context) {
    final cameraReady = faceStatus == FaceStatus.verified || cameraLocked;
    final allDone = cameraLocked && audioVerified;

    String label;
    IconData icon;
    bool active;
    VoidCallback onPress;

    if (step == 'camera') {
      label = 'Next';
      icon = Icons.arrow_forward;
      active = cameraReady;
      onPress = onNext;
    } else {
      label = allDone ? 'Hardware Verified & Continue' : 'Continue';
      icon = allDone ? Icons.verified_user : Icons.arrow_forward;
      active = allDone;
      onPress = onFinish;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom, left: 22, right: 22),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: active ? onPress : null,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: active ? null : const Color(0xFFF3F4F6),
                gradient: active
                    ? LinearGradient(
                        colors: (allDone && step == 'audio')
                            ? const [Color(0xFF0066FF), Color(0xFF1D4ED8)]
                            : const [Color(0xFF16A34A), Color(0xFF15803D)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFF9CA3AF),
                        fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: active ? 0.5 : 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      size: active ? 18 : 16,
                      color: active ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
