import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/features/ai_grammar/repositories/grammar_repository.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_audio_player_provider.dart';
import 'package:eduprova/core/services/deepgram_stt_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ShadowingSection extends ConsumerStatefulWidget {
  final AppDesignExtension themeExt;
  final VoidCallback onBack;

  const ShadowingSection({
    super.key,
    required this.themeExt,
    required this.onBack,
  });

  @override
  ConsumerState<ShadowingSection> createState() => _ShadowingSectionState();
}

class _ShadowingSectionState extends ConsumerState<ShadowingSection>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isAnalysing = false;

  GrammarPracticeQuestion? _currentQuestion;
  GrammarAnalysisResult? _lastAnalysis;

  final DeepgramSttService _sttService = DeepgramSttService();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
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
      _lastWords = '';
    });
    try {
      final repo = ref.read(grammarRepositoryProvider);
      final question = await repo.fetchPracticeQuestion('shadowing');
      if (mounted) {
        setState(() {
          _currentQuestion = question;
          _isLoading = false;
        });
        if (question.audio != null) {
          _playModelAudio();
        }
      }
    } catch (e) {
      debugPrint('Question load error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _playModelAudio() {
    if (_currentQuestion?.audio != null) {
      ref
          .read(grammarAudioPlayerProvider.notifier)
          .playBase64(_currentQuestion!.audio!);
    }
  }

  Future<void> _toggleListening() async {
    if (_isLoading || _isAnalysing) return;

    if (_isListening) {
      await _sttService.stop();
      if (mounted) setState(() => _isListening = false);
      if (_lastWords.isNotEmpty) {
        _analyzeResponse(_lastWords);
      }
    } else {
      if (mounted) {
        setState(() {
          _lastWords = '';
          _isListening = true;
        });
      }
      await _sttService.start(
        onTranscript: (text) {
          if (mounted) {
            setState(() {
              _lastWords = text;
            });
          }
        },
        onError: (err) {
          if (mounted) setState(() => _isListening = false);
        },
        onDone: () {
          if (mounted) setState(() => _isListening = false);
        },
      );
    }
  }

  Future<void> _analyzeResponse(String text) async {
    if (text.trim().isEmpty || _isAnalysing) return;

    if (mounted) setState(() => _isAnalysing = true);

    try {
      final repo = ref.read(grammarRepositoryProvider);
      final result = await repo.analyzePracticeResponse(
        _currentQuestion?.question ?? '',
        text,
      );

      if (!mounted) return;

      setState(() {
        _lastAnalysis = result;
        _isAnalysing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalysing = false);
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _sttService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final audioState = ref.watch(grammarAudioPlayerProvider);
    _isPlaying = audioState;

    return Skeletonizer(
      enabled: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme),
            const SizedBox(height: 30),
            _buildShadowingContent(colorScheme),
            const SizedBox(height: 40),
            if (_lastAnalysis != null) ...[
              Text(
                'YOUR PROGRESS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.themeExt.secondaryText,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              _buildProgressCard(colorScheme),
              const SizedBox(height: 20),
              _buildFeedbackCard(colorScheme),
            ] else if (!_isLoading) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Practice the sentence above to see your scores.',
                    style: TextStyle(
                      color: widget.themeExt.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton.icon(
                  onPressed: _loadInitialQuestion,
                  icon: Text(
                    'Next practice sentence',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.themeExt.secondaryText,
                    ),
                  ),
                  label: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: widget.themeExt.secondaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shadowing Mode',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Listen and repeat to perfect your fluency.',
              style: TextStyle(
                fontSize: 16,
                color: widget.themeExt.secondaryText,
              ),
            ),
          ],
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _loadInitialQuestion,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.themeExt.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.themeExt.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.shuffle, size: 18, color: colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    'Shuffle',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShadowingContent(ColorScheme colorScheme) {
    final question = _currentQuestion?.question ?? 'Loading question...';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.themeExt.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentQuestion?.difficulty.toUpperCase() ??
                          'INTERMEDIATE',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ${_currentQuestion?.topic ?? 'Daily Routine'}',
                    style: TextStyle(
                      color: widget.themeExt.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (_isPlaying || _isListening) _buildWaveForm(),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Shadowing Practice',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            question,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Icon(Icons.bar_chart, size: 16, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                _isPlaying
                    ? 'PLAYING MODEL..'
                    : (_isListening ? 'LISTENING..' : 'READY'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2563EB),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 16),
              if (_isListening)
                Expanded(
                  child: Text(
                    _lastWords.isEmpty ? 'Say it out loud...' : _lastWords,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.themeExt.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _playModelAudio,
                icon: const Icon(Icons.volume_up, size: 24),
                color: const Color(0xFF2563EB),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildActionButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildWaveForm() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (index) {
        return AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            double value =
                (math.sin(_waveController.value * 2 * math.pi + index) + 1) / 2;
            return Container(
              width: 3,
              height: 10 + (20 * value),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: index % 2 == 0
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildActionButton(ColorScheme colorScheme) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _toggleListening,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isListening
                  ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                  : [const Color(0xFF2563EB), const Color(0xFFC026D3)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    (_isListening
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF2563EB))
                        .withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isAnalysing)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  _isListening ? Icons.stop_circle : Icons.mic_none,
                  color: Colors.white,
                  size: 24,
                ),
              const SizedBox(width: 12),
              Text(
                _isAnalysing
                    ? 'ANALYSING..'
                    : (_isListening ? 'STOP RECORDING' : 'START PRACTICE'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(ColorScheme colorScheme) {
    if (_lastAnalysis == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.themeExt.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: '"${_lastAnalysis?.transcription ?? _lastWords}"',
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_lastAnalysis?.fluencyScore ?? 0}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const Text(
                    'FLUENCY SCORE',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Icon(
                          i < ((_lastAnalysis?.fluencyScore ?? 0) / 20).round()
                              ? Icons.star
                              : Icons.star_border,
                          color: const Color(0xFFF59E0B),
                          size: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'POINTS EARNED: +10',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.themeExt.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(ColorScheme colorScheme) {
    if (_lastAnalysis == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.themeExt.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'AI Feedback',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_lastAnalysis?.suggestions['alerts'] != null)
            ...(_lastAnalysis!.suggestions['alerts'] as List).map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFeedbackItem(alert.toString()),
              ),
            ),
          if (_lastAnalysis?.improvedResponse.isNotEmpty ?? false)
            _buildFeedbackItem(
              'Try this for better natural flow: "${_lastAnalysis!.improvedResponse}"',
            ),

          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ACCURACY',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    '${_lastAnalysis?.grammarScore ?? 0}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_lastAnalysis?.grammarScore ?? 0).toDouble() / 100.0,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF059669),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.check_circle, size: 12, color: Color(0xFF059669)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
