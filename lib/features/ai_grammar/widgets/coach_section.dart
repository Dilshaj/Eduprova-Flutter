import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/core/services/deepgram_stt_service.dart';
import 'package:eduprova/features/ai_grammar/repositories/grammar_repository.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_audio_player_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CoachSection extends ConsumerStatefulWidget {
  final AppDesignExtension themeExt;
  final VoidCallback onBack;

  const CoachSection({super.key, required this.themeExt, required this.onBack});

  @override
  ConsumerState<CoachSection> createState() => _CoachSectionState();
}

class _CoachSectionState extends ConsumerState<CoachSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _voiceController;
  final ScrollController _chatScrollController = ScrollController();

  bool _isMuted = false;
  bool _isLoading = true;
  bool _isAnalysing = false;

  final DeepgramSttService _sttService = DeepgramSttService();
  bool _isListening = false;
  String _lastWords = '';

  GrammarPracticeQuestion? _currentQuestion;
  GrammarAnalysisResult? _lastAnalysis;

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _voiceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _loadInitialQuestion();
  }

  Future<void> _loadInitialQuestion() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _lastAnalysis = null;
      _messages.clear();
    });
    try {
      final repo = ref.read(grammarRepositoryProvider);
      final question = await repo.fetchPracticeQuestion('fluency');
      if (mounted) {
        setState(() {
          _currentQuestion = question;
          _messages.add({
            'isUser': false,
            'text': question.question,
            'time': 'Just now',
            'type': 'coach',
          });
          _isLoading = false;
        });
        if (question.audio != null) {
          ref
              .read(grammarAudioPlayerProvider.notifier)
              .playBase64(question.audio!);
        }
      }
    } catch (e) {
      debugPrint('Question load error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add({
            'isUser': false,
            'text': "Failed to load question: ${e.toString()}",
            'time': 'Just now',
            'type': 'coach',
          });
        });
      }
    }
  }

  Future<void> _toggleListening() async {
    if (_isMuted || _isAnalysing) return;

    if (_isListening) {
      await _sttService.stop();
      setState(() => _isListening = false);
      if (_lastWords.isNotEmpty) {
        _sendMessage(_lastWords);
      }
    } else {
      setState(() {
        _lastWords = '';
        _isListening = true;
      });
      await _sttService.start(
        onTranscript: (text) {
          setState(() {
            _lastWords = text;
          });
        },
        onError: (err) {
          setState(() => _isListening = false);
        },
        onDone: () {
          setState(() => _isListening = false);
        },
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isAnalysing) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text, 'time': 'Just now'});
      _lastWords = '';
      _isAnalysing = true;
    });

    _scrollToBottom();

    try {
      final repo = ref.read(grammarRepositoryProvider);
      final result = await repo.analyzePracticeResponse(
        _currentQuestion?.question ?? '',
        text,
        audio: null,
      );

      if (!mounted) return;

      setState(() {
        _lastAnalysis = result;
        _messages.add({
          'isUser': false,
          'text': result.improvedResponse,
          'time': 'Just now',
          'type': 'coach',
          'alternatives': [result.improvedResponse],
          'alerts': result.suggestions['alerts']?.cast<String>() ?? [],
        });
        _isAnalysing = false;
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('Analysis error: $e');
      if (mounted) {
        setState(() {
          _isAnalysing = false;
          _messages.add({
            'isUser': false,
            'text': "Analysis failed: ${e.toString()}",
            'time': 'Just now',
            'type': 'coach',
          });
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _voiceController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Skeletonizer(
      enabled: _isLoading,
      child: Column(
        children: [
          // Top compact metrics & AI Status
          _buildTopCompactHeader(colorScheme),

          // Chat Viewport
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatMessage(msg, colorScheme);
              },
            ),
          ),

          // Chat Input
          _buildChatInput(colorScheme),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTopCompactHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        boxShadow: [
          BoxShadow(
            color: widget.themeExt.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=300',
                        ),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI COACH',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Live Intelligence Active',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF166534),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMuted = !_isMuted;
                      if (_isMuted && _isListening) {
                        // _speechToText.stop();
                        _isListening = false;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isMuted
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isMuted
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFE0E7FF),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isMuted ? Icons.mic_off : Icons.mic_none,
                          size: 16,
                          color: _isMuted
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF0066FF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isMuted ? 'UNMUTE' : 'MUTE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _isMuted
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF0066FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetricBadge(
                'FLUENCY',
                '${_lastAnalysis?.fluencyScore ?? 0}%',
                const Color(0xFF0066FF),
                Icons.insights,
              ),
              const SizedBox(width: 12),
              _buildMetricBadge(
                'GRAMMAR',
                '${_lastAnalysis?.grammarScore ?? 0}/100',
                const Color(0xFF059669),
                Icons.spellcheck,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: widget.themeExt.secondaryText,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> msg, ColorScheme colorScheme) {
    final bool isUser = msg['isUser'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0066FF), Color(0xFFC026D3)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF0066FF), Color(0xFF6366F1)],
                              )
                            : null,
                        color: isUser ? null : widget.themeExt.cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(24),
                          topRight: const Radius.circular(24),
                          bottomLeft: Radius.circular(isUser ? 24 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isUser
                                ? const Color(
                                    0xFF0066FF,
                                  ).withValues(alpha: 0.05)
                                : widget.themeExt.shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          fontSize: 16,
                          color: isUser
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                          fontWeight: isUser
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (msg['label'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 12,
                              color: Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              msg['label'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (isUser)
                const SizedBox(
                  width: 48,
                ), // Padding on the left for user messages
            ],
          ),
          if (msg['alternatives'] != null)
            ...List.generate(
              msg['alternatives'].length,
              (i) => _buildSubBubble(
                msg['alternatives'][i],
                const Color(0xFFE11D48),
                'BETTER ALTERNATIVE',
                Icons.auto_fix_high,
              ),
            ),
          if (msg['alerts'] != null)
            ...List.generate(
              msg['alerts'].length,
              (i) => _buildSubBubble(
                msg['alerts'][i],
                const Color(0xFFF59E0B),
                'PACING ALERT',
                Icons.speed,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubBubble(
    String text,
    Color color,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withValues(alpha: 0.9),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isMuted
                  ? 'Microphone muted'
                  : (_isListening
                        ? (_lastWords.isEmpty ? 'Listening...' : _lastWords)
                        : (_lastWords.isNotEmpty
                              ? _lastWords
                              : 'Tap mic to dictate...')),
              style: TextStyle(
                color: _isMuted
                    ? const Color(0xFFEF4444)
                    : widget.themeExt.secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (_isMuted) {
                  setState(() => _isMuted = false);
                }
                _toggleListening();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isMuted
                        ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                        : (_isListening
                              ? [
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669),
                                ]
                              : [
                                  const Color(0xFF0066FF),
                                  const Color(0xFF7C3AED),
                                ]),
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isMuted
                                  ? const Color(0xFFEF4444)
                                  : (_isListening
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF0066FF)))
                              .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _isMuted
                      ? Icons.mic_off_rounded
                      : (_isListening ? Icons.stop_rounded : Icons.mic_rounded),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          if (_lastWords.isNotEmpty && !_isListening) ...[
            const SizedBox(width: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final text = _lastWords;
                  setState(() {
                    _lastWords = '';
                  });
                  _sendMessage(text);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
