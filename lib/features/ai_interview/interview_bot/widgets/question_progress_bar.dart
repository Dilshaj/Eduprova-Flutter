import 'package:flutter/material.dart';
import '../../widgets/ai_theme.dart';

class QuestionProgressBar extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;

  const QuestionProgressBar({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    if (totalQuestions == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            'Q ${currentQuestionIndex + 1}/$totalQuestions',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: t.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ((currentQuestionIndex + 1) / totalQuestions),
                minHeight: 4,
                backgroundColor: t.barTrack,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
