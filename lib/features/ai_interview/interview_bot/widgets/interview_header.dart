import 'package:flutter/material.dart';
import '../../widgets/ai_theme.dart';

class InterviewHeader extends StatelessWidget {
  final String interviewerName;
  final IconData interviewerIcon;
  final String role;
  final String formattedTime;
  final bool isEndingSession;
  final VoidCallback onEndSession;
  final bool isMale;

  const InterviewHeader({
    super.key,
    required this.interviewerName,
    required this.interviewerIcon,
    required this.role,
    required this.formattedTime,
    required this.isEndingSession,
    required this.onEndSession,
    required this.isMale,
  });

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isMale
                        ? const [Color(0xFF3B82F6), Color(0xFF1E3A8A)]
                        : const [Color(0xFF3B82F6), Color(0xFFD946EF)],
                    begin: .topLeft,
                    end: .bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(interviewerIcon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    interviewerName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: t.textPrimary,
                    ),
                  ),
                  Text(
                    '${role.toUpperCase()} INTERVIEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: t.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.schedule, color: t.textMuted, size: 16),
              const SizedBox(width: 4),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: t.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: isEndingSession ? null : onEndSession,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isEndingSession
                        ? Colors.grey
                        : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isEndingSession
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'END',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
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
