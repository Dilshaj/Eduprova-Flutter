import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'dart:math' as math;

class ShadowingSection extends StatefulWidget {
  final AppDesignExtension themeExt;
  final VoidCallback onBack;

  const ShadowingSection({
    super.key,
    required this.themeExt,
    required this.onBack,
  });

  @override
  State<ShadowingSection> createState() => _ShadowingSectionState();
}

class _ShadowingSectionState extends State<ShadowingSection> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _progressController;
  bool _isPlaying = false;
  double _audioProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..addListener(() {
        setState(() {
          _audioProgress = _progressController.value;
        });
      });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _toggleAudio() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _progressController.forward();
      } else {
        _progressController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colorScheme),
          const SizedBox(height: 30),
          _buildShadowingContent(colorScheme),
          const SizedBox(height: 40),
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
          const SizedBox(height: 40),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton.icon(
                onPressed: () {},
                icon: Text(
                  'Next practice sentence',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.themeExt.secondaryText),
                ),
                label: Icon(Icons.arrow_forward_ios, size: 16, color: widget.themeExt.secondaryText),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
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
            onTap: () {}, // Add logic if needed
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'INTERMEDIATE',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Daily Routine',
                    style: TextStyle(
                      color: widget.themeExt.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _buildWaveForm(),
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
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildTextWord('"Establishing'),
              _buildTextWord('a'),
              _buildHighlightedWord('regular exercise'),
              _buildHighlightedWord('routine'),
              _buildTextWord('is'),
              _buildTextWord('essential'),
              _buildTextWord('for'),
              _buildTextWord('maintaining'),
              _buildTextWord('both'),
              _buildTextWord('your'),
              _buildTextWord('physical'),
              _buildTextWord('fitness'),
              _buildTextWord('and'),
              _buildTextWord('your'),
              _buildHighlightedWord('mental well-being'),
              _buildTextWord('."'),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Icon(Icons.bar_chart, size: 16, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                _isPlaying ? 'PLAYING AUDIO..' : 'AUDIO READY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2563EB),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _audioProgress,
                    backgroundColor: widget.themeExt.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '0:${(_audioProgress * 16).toInt().toString().padLeft(2, '0')} / 0:16',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.themeExt.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.volume_up, size: 20, color: widget.themeExt.secondaryText),
            ],
          ),
          const SizedBox(height: 30),
          _buildActionButton(),
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
            double value = (math.sin(_waveController.value * 2 * math.pi + index) + 1) / 2;
            return Container(
              width: 3,
              height: 10 + (20 * value),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTextWord(String text) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildHighlightedWord(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF166534),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _toggleAudio,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFFC026D3)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isPlaying ? Icons.pause_circle : Icons.mic_none, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                _isPlaying ? 'STOP PRACTICE' : 'PRACTICE AGAIN',
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
                const TextSpan(text: '"Establishing a regular '),
                const TextSpan(
                  text: 'exercise',
                  style: TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' routine is essential for maintaining '),
                const TextSpan(
                  text: 'both',
                  style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' your physical fitness and your mental well-being."'),
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
                    '94%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.auto_graph, size: 14, color: Color(0xFF059669)),
                      const SizedBox(width: 4),
                      const Text(
                        '+2% vs. last',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [for (int i = 0; i < 4; i++) const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18), const Icon(Icons.star_border, color: Color(0xFFF59E0B), size: 18)],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DAILY ROUTINE • +10 PTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.themeExt.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.themeExt.borderColor),
                ),
                child: Icon(Icons.play_arrow, color: widget.themeExt.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(ColorScheme colorScheme) {
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
                child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2563EB)),
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
          _buildFeedbackItem(
            'Your rhythm and intonation are highly accurate. Focus on the word "exercise"—the "x" sound was slightly muffled.',
          ),
          const SizedBox(height: 20),
          _buildFeedbackItem(
            'Your pacing on the second half of the sentence was perfect, showing a strong grasp of natural speech patterns.',
          ),
          const SizedBox(height: 20),
          _buildFeedbackItem(
            'Try emphasizing the word "essential" a bit more in your next attempt to sound more authoritative.',
          ),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'OVERALL SENTIMENT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Text(
                    'POSITIVE',
                    style: TextStyle(
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
                child: const LinearProgressIndicator(
                  value: 0.85,
                  backgroundColor: Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
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
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: const Color(0xFF475569),
        height: 1.6,
      ),
    );
  }
}
