import 'package:flutter/material.dart';
import '../../widgets/ai_theme.dart';

class InterviewInputArea extends StatelessWidget {
  final bool isListening;
  final bool isAiSpeaking;
  final String transcript;
  final VoidCallback onSendMessage;
  final VoidCallback onStartListening;

  const InterviewInputArea({
    super.key,
    required this.isListening,
    required this.isAiSpeaking,
    required this.transcript,
    required this.onSendMessage,
    required this.onStartListening,
  });

  @override
  Widget build(BuildContext context) {
    if (isAiSpeaking) return const SizedBox.shrink();

    final t = AiTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: .end,
            children: [
              Expanded(
                child: Text(
                  isListening
                      ? (transcript.isNotEmpty
                            ? transcript
                            : "I'm listening...")
                      : 'Tap to speak',
                  style: TextStyle(
                    color: t.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: isListening ? onSendMessage : onStartListening,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isListening
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isListening
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF3B82F6))
                                .withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    isListening ? Icons.send : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
