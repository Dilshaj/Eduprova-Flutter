import 'dart:ui';
import 'package:eduprova/features/ai_grammar/providers/grammar_socket_provider.dart';
import 'package:eduprova/features/auth/providers/auth_provider.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class RefinerSection extends ConsumerStatefulWidget {
  final AppDesignExtension themeExt;
  final VoidCallback onBack;

  const RefinerSection({
    super.key,
    required this.themeExt,
    required this.onBack,
  });

  @override
  ConsumerState<RefinerSection> createState() => _RefinerSectionState();
}

class _RefinerSectionState extends ConsumerState<RefinerSection> {
  String _selectedTone = 'PROFESSIONAL';
  final TextEditingController _originalTextController = TextEditingController();

  @override
  void dispose() {
    _originalTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketStatus = ref.watch(grammarSocketProvider);
    final result = socketStatus.correctionResult;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          _buildRefinerMainCard(socketStatus),
          if (result != null) ...[
            const SizedBox(height: 20),
            _buildRefinementScoreCard(result),
            const SizedBox(height: 20),
            _buildKeyImprovementsCard(result),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRefinerMainCard(GrammarSocketState socketStatus) {
    final result = socketStatus.correctionResult;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(32),
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
          _buildCardHeader(socketStatus.isConnected),
          const SizedBox(height: 24),
          _buildOriginalTextInput(socketStatus.isRefining),
          if (result != null) ...[
            const SizedBox(height: 24),
            _buildRefinedVersion(result),
          ],
          const SizedBox(height: 24),
          _buildToneSelectors(socketStatus.isRefining),
          const SizedBox(height: 24),
          _buildRefineButton(socketStatus.isRefining, socketStatus.isConnected),
        ],
      ),
    );
  }

  Widget _buildCardHeader(bool isConnected) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              const Icon(Icons.auto_awesome_outlined, color: Color(0xFF7C3AED), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'AI TEXT REFINER',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
            letterSpacing: 1.1,
          ),
        ),
        const Spacer(),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isConnected ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isConnected ? 'API CONNECTED' : 'CONNECTING...',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isConnected ? const Color(0xFF166534) : const Color(0xFF991B1B),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOriginalTextInput(bool isRefining) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ORIGINAL TEXT',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: widget.themeExt.secondaryText,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () => _originalTextController.clear(),
              child: const Text(
                'CLEAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.themeExt.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.themeExt.borderColor),
          ),
          child: TextField(
            controller: _originalTextController,
            maxLines: 4,
            enabled: !isRefining,
            style: TextStyle(
                fontSize: 15, color: widget.themeExt.secondaryText, height: 1.6),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Type a sentence you\'d like to improve...',
              hintStyle: TextStyle(
                  color: widget.themeExt.secondaryText.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefinedVersion(CorrectionResult result) {
    final text = result.refinedText ?? result.corrected;
    final highlights =
        result.highlights?.map((e) => e.toString()).toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REFINED VERSION',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC026D3),
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    child: Icon(Icons.copy_outlined,
                        size: 18, color: widget.themeExt.secondaryText),
                  ),
                ),
                const SizedBox(width: 16),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _handleRefine,
                    child: Icon(Icons.refresh,
                        size: 18, color: widget.themeExt.secondaryText),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFC026D3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: const Color(0xFFC026D3).withValues(alpha: 0.2)),
          ),
          child: _renderHighlightedText(text, highlights),
        ),
      ],
    );
  }

  Widget _renderHighlightedText(String text, List<String> highlights) {
    if (highlights.isEmpty) {
      return Text(
        text,
        style: TextStyle(
            fontSize: 16, color: Theme.of(context).colorScheme.onSurface, height: 1.6),
      );
    }

    final spans = <InlineSpan>[];
    String remainingText = text;

    // Sort highlights by length descending to match longest phrases first
    final sortedHighlights = List<String>.from(highlights)
      ..sort((a, b) => b.length.compareTo(a.length));

    while (remainingText.isNotEmpty) {
      int nextMatchIndex = -1;
      String currentMatch = '';

      for (final highlight in sortedHighlights) {
        final index =
            remainingText.toLowerCase().indexOf(highlight.toLowerCase());
        if (index != -1 && (nextMatchIndex == -1 || index < nextMatchIndex)) {
          nextMatchIndex = index;
          currentMatch = remainingText.substring(index, index + highlight.length);
        }
      }

      if (nextMatchIndex == -1) {
        spans.add(TextSpan(text: remainingText));
        break;
      }

      if (nextMatchIndex > 0) {
        spans.add(TextSpan(text: remainingText.substring(0, nextMatchIndex)));
      }

      spans.add(_buildHighlightedSpan(currentMatch));
      remainingText =
          remainingText.substring(nextMatchIndex + currentMatch.length);
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: 16, color: Theme.of(context).colorScheme.onSurface, height: 1.6),
        children: spans,
      ),
    );
  }

  InlineSpan _buildHighlightedSpan(String text) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildToneSelectors(bool isRefining) {
    final tones = [
      'PROFESSIONAL',
      'CASUAL',
      'CONCISE',
      'ACADEMIC',
      'TECHNICAL',
      'CREATIVE'
    ];
    return IgnorePointer(
      ignoring: isRefining,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (var tone in tones)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTone = tone),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTone == tone
                            ? const Color(0xFF2563EB)
                            : widget.themeExt.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedTone == tone
                              ? const Color(0xFF2563EB)
                              : widget.themeExt.borderColor,
                        ),
                      ),
                      child: Text(
                        tone,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selectedTone == tone
                              ? Colors.white
                              : widget.themeExt.secondaryText,
                        ),
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

  void _handleRefine() {
    if (_originalTextController.text.trim().isEmpty) return;
    final user = ref.read(authProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    ref.read(grammarSocketProvider.notifier).correctSentence(
          _originalTextController.text,
          user.id,
          tone: _selectedTone,
        );
  }

  Widget _buildRefineButton(bool isRefining, bool isConnected) {
    return MouseRegion(
      cursor: isRefining || !isConnected
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isRefining || !isConnected ? null : _handleRefine,
        child: Opacity(
          opacity: isRefining || !isConnected ? 0.7 : 1.0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
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
              mainAxisAlignment: .center,
              children: [
                if (isRefining)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.auto_fix_high, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  isRefining ? 'REFINING...' : 'REFINE TEXT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefinementScoreCard(CorrectionResult result) {
    final scoreImprovement = result.scoreImprovement ?? 0;
    final metrics = result.metrics ?? {};
    final clarity = (metrics['clarity'] ?? 0).toDouble();
    final tone = (metrics['tone'] ?? 0).toDouble();
    final vocabulary = (metrics['vocabulary'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: widget.themeExt.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REFINEMENT SCORE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.themeExt.secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+$scoreImprovement% Improvement',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildScoreMetric('CLARITY', clarity, const Color(0xFF2563EB)),
          const SizedBox(height: 16),
          _buildScoreMetric('TONE MATCH', tone, const Color(0xFFC026D3)),
          const SizedBox(height: 16),
          _buildScoreMetric('VOCABULARY', vocabulary, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildScoreMetric(String label, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.themeExt.secondaryText),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildKeyImprovementsCard(CorrectionResult result) {
    final keyImprovements = result.keyImprovements ?? [];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: widget.themeExt.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY IMPROVEMENTS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2563EB),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          if (keyImprovements.isEmpty)
            const Text(
              'Grammar corrected properly.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
            )
          else
            for (var improvement in keyImprovements) ...[
              _buildImprovementItem(
                (improvement['title'] ?? '').toString().toUpperCase(),
                (improvement['description'] ?? '').toString(),
              ),
              if (improvement != keyImprovements.last) const SizedBox(height: 24),
            ],
        ],
      ),
    );
  }

  Widget _buildImprovementItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.themeExt.secondaryText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

