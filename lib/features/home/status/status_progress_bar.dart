import 'package:flutter/material.dart';

class StatusProgressBar extends StatelessWidget {
  final int count;
  final int currentIndex;
  final double activeProgress;

  const StatusProgressBar({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.activeProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: _ProgressBarSegment(progress: _getSegmentProgress(index)),
          ),
        );
      }),
    );
  }

  double _getSegmentProgress(int index) {
    if (index < currentIndex) return 1.0;
    if (index == currentIndex) return activeProgress;
    return 0.0;
  }
}

class _ProgressBarSegment extends StatelessWidget {
  final double progress;

  const _ProgressBarSegment({required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 2.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              height: 2.5,
              width: constraints.maxWidth * progress,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      },
    );
  }
}
