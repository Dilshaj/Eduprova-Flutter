import 'package:flutter/material.dart';
import '../../widgets/ai_theme.dart';
import 'voice_analysis_bars.dart';

class ChatMessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final ScrollController scrollController;
  final bool isListening;
  final double speechLevel;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.isListening,
    required this.speechLevel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: messages.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return _buildVoiceAnalysisIndicator(context, t);
        }

        final msg = messages[index];
        final isAI = msg['isAI'] as bool;

        return Align(
          alignment: isAI ? .centerLeft : .centerRight,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAI ? t.cardBg : const Color(0xFF3B82F6),
              borderRadius: .only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: .circular(isAI ? 4 : 20),
                bottomRight: .circular(isAI ? 20 : 4),
              ),
              boxShadow: isAI ? t.cardShadow : null,
              border: isAI ? Border.all(color: t.cardBorder) : null,
            ),
            child: Text(
              msg['text'] as String,
              style: TextStyle(
                color: isAI ? t.textPrimary : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceAnalysisIndicator(BuildContext context, AiTheme t) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 48),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Row(
            mainAxisSize: .min,
            children: [
              VoiceAnalysisBars(
                speechLevel: speechLevel,
                isListening: isListening,
              ),
              const SizedBox(width: 8),
              Text(
                'VOICE ANALYSIS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: t.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
