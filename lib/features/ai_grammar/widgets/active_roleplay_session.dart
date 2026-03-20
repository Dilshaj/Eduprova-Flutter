import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/features/ai_grammar/widgets/live_session_overlay.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_socket_provider.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_stt_provider.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_audio_player_provider.dart';

class ActiveRoleplaySession extends ConsumerStatefulWidget {
  final String title;
  final String difficulty;
  final String roleType;
  final AppDesignExtension themeExt;
  final VoidCallback onBack;
  final Map<String, dynamic>? config;

  const ActiveRoleplaySession({
    super.key,
    required this.title,
    required this.difficulty,
    required this.roleType,
    required this.themeExt,
    required this.onBack,
    this.config,
  });

  @override
  ConsumerState<ActiveRoleplaySession> createState() =>
      _ActiveRoleplaySessionState();
}

class _ActiveRoleplaySessionState extends ConsumerState<ActiveRoleplaySession> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start roleplay on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(grammarSocketProvider.notifier)
          .startRoleplay(
            roleType: widget.roleType,
            difficulty: widget.difficulty,
            experienceLevel: widget.config?['experienceLevel'],
            companyType: widget.config?['companyType'],
            jobTitle: widget.config?['jobTitle'],
            techStack: widget.config?['techStack'] != null
                ? List<String>.from(widget.config!['techStack'])
                : null,
            seniorityLevel: widget.config?['seniorityLevel'],
            customPrompt: widget.config?['customPrompt'],
          );
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(grammarSocketProvider.notifier).sendUserText(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    ref.read(grammarAudioPlayerProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final socketState = ref.watch(grammarSocketProvider);
    final isAiSpeakingAudibly = ref.watch(grammarAudioPlayerProvider);
    final sttState = ref.watch(grammarSttProvider);
    final isAiActive = socketState.isAiSpeaking || isAiSpeakingAudibly;

    // Auto scroll when new messages arrive
    ref.listen(grammarSocketProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    // Update text field when STT transcript changes
    ref.listen(grammarSttProvider, (previous, next) {
      if (next.transcript.isNotEmpty &&
          next.transcript != previous?.transcript) {
        _controller.text = next.transcript;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });

    return Container(
      color: widget.themeExt.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildHeader(colorScheme),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: socketState.messages.length,
              itemBuilder: (context, index) {
                final message = socketState.messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          if (socketState.isAiSpeaking)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildVoiceWaves(),
            ),
          _buildInputArea(colorScheme, sttState, isAiActive),
        ],
      ),
    );
  }

  Widget _buildVoiceWaves() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 4; i++)
          Container(
            width: 4,
            height: 15,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          'AI is speaking...',
          style: TextStyle(
            color: widget.themeExt.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                ),
              ),
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'END SESSION',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('LIVE Feedback', widget.themeExt.borderColor),
              const SizedBox(width: 8),
              _buildBadge(
                widget.difficulty,
                const Color(0xFF2563EB).withValues(alpha: 0.1),
                textColor: const Color(0xFF2563EB),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, {Color? textColor}) {
    final isLive = label == 'LIVE SESSION';
    return MouseRegion(
      cursor: isLive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isLive
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiveSessionOverlay(
                      themeExt: widget.themeExt,
                      onFinish: () => Navigator.pop(context),
                    ),
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            border: isLive
                ? Border.all(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  )
                : null,
          ),
          child: Row(
            children: [
              if (label.contains('ADVANCED'))
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.bar_chart,
                    size: 14,
                    color: Color(0xFF2563EB),
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? widget.themeExt.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(GrammarMessage message) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              isUser ? "YOU" : "AI",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2563EB),
                letterSpacing: 1.0,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(
                    0xFF2563EB,
                  ).withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.psychology_outlined,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: .end,
                  children: [
                    Container(
                      padding: const .all(20),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const .new(0xFF2563EB)
                            : widget.themeExt.cardColor,
                        borderRadius: .only(
                          topLeft: const .circular(24),
                          topRight: const .circular(24),
                          bottomLeft: .circular(isUser ? 24 : 4),
                          bottomRight: .circular(isUser ? 4 : 24),
                        ),
                        boxShadow: [
                          .new(
                            color: widget.themeExt.shadowColor,
                            blurRadius: 10,
                            offset: const .new(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: .new(
                          color: isUser ? Colors.white : colorScheme.onSurface,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (isUser && message.feedback != null)
                      Padding(
                        padding: const .only(top: 8, right: 4),
                        child: InkWell(
                          onTap: () => _showFeedbackDialog(message.feedback!),
                          borderRadius: .circular(20),
                          child: Padding(
                            padding: const .symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: .min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Review Feedback',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: .bold,
                                    color: const .new(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(
                    0xFF2563EB,
                  ).withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(
    ColorScheme colorScheme,
    GrammarSttState sttState,
    bool isAiActive,
  ) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding > 10 ? 0 : 12),
      decoration: BoxDecoration(color: widget.themeExt.scaffoldBackgroundColor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: widget.themeExt.cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: widget.themeExt.borderColor),
          boxShadow: [
            BoxShadow(
              color: widget.themeExt.shadowColor,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: isAiActive
                    ? null
                    : () {
                        if (sttState.isListening) {
                          ref.read(grammarSttProvider.notifier).stopListening();
                        } else {
                          ref
                              .read(grammarSttProvider.notifier)
                              .startListening();
                        }
                      },
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: isAiActive
                        ? widget.themeExt.secondaryText.withValues(alpha: 0.1)
                        : (sttState.isListening
                              ? const Color(0xFF0066FF)
                              : widget.themeExt.cardColor),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    sttState.isListening ? Icons.mic : Icons.mic_none_outlined,
                    color: sttState.isListening
                        ? const Color(0xFF2563EB)
                        : widget.themeExt.secondaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: 3,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: sttState.isListening
                        ? 'Listening...'
                        : 'Type your response here',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintStyle: TextStyle(
                      color: widget.themeExt.secondaryText.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Send',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.near_me_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(Map<String, dynamic> feedback) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExt = widget.themeExt;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const .symmetric(horizontal: 16),
        child: Container(
          padding: const .all(24),
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            borderRadius: .circular(32),
            border: .all(color: themeExt.borderColor),
            boxShadow: [
              .new(
                color: themeExt.shadowColor,
                blurRadius: 24,
                offset: const .new(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Grammar Feedback',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: .bold,
                      fontSize: 22,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (feedback['grammarFix'] != null) ...[
                const Text(
                  'CORRECTED VERSION',
                  style: .new(
                    fontSize: 11,
                    fontWeight: .w800,
                    color: .new(0xFF3B82F6),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const .all(20),
                  decoration: BoxDecoration(
                    color: themeExt.scaffoldBackgroundColor,
                    borderRadius: .circular(20),
                    border: .all(
                      color: Color(0xFF3B82F6).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    feedback['grammarFix'],
                    style: .new(
                      fontSize: 16,
                      fontWeight: .w600,
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (feedback['betterWay'] != null) ...[
                const Text(
                  'BETTER PHRASING',
                  style: .new(
                    fontSize: 11,
                    fontWeight: .w800,
                    color: .new(0xFF10B981),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const .all(20),
                  decoration: BoxDecoration(
                    color: themeExt.scaffoldBackgroundColor,
                    borderRadius: .circular(20),
                    border: .all(
                      color: Color(0xFF10B981).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    feedback['betterWay'],
                    style: .new(
                      fontSize: 16,
                      fontWeight: .w600,
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Align(
                alignment: .centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const .symmetric(horizontal: 24, vertical: 12),
                    foregroundColor: const .new(0xFF3B82F6),
                  ),
                  child: const Text(
                    'GOT IT',
                    style: .new(
                      fontWeight: .w900,
                      letterSpacing: 1.0,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
