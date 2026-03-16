import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'dart:ui';

class RefinerSection extends StatefulWidget {
  final AppDesignExtension themeExt;
  final VoidCallback onBack;

  const RefinerSection({
    super.key,
    required this.themeExt,
    required this.onBack,
  });

  @override
  State<RefinerSection> createState() => _RefinerSectionState();
}

class _RefinerSectionState extends State<RefinerSection> {
  String _selectedTone = 'PROFESSIONAL';
  final TextEditingController _originalTextController = TextEditingController(
    text: 'I am writing to you because I want to ask for a meeting next week to talk about the project status. I think we have some problems that we need to solve quickly.',
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          _buildRefinerMainCard(colorScheme),
          const SizedBox(height: 20),
          _buildRefinementScoreCard(colorScheme),
          const SizedBox(height: 20),
          _buildKeyImprovementsCard(colorScheme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRefinerMainCard(ColorScheme colorScheme) {
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
          _buildCardHeader(),
          const SizedBox(height: 24),
          _buildOriginalTextInput(),
          const SizedBox(height: 24),
          _buildRefinedVersion(),
          const SizedBox(height: 24),
          _buildToneSelectors(),
          const SizedBox(height: 24),
          _buildRefineButton(),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome_outlined, color: Color(0xFF7C3AED), size: 20),
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
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: const Icon(Icons.history, color: Color(0xFF94A3B8), size: 22),
        ),
        const SizedBox(width: 16),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: const Icon(Icons.settings_outlined, color: Color(0xFF94A3B8), size: 22),
        ),
      ],
    );
  }

  Widget _buildOriginalTextInput() {
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
            style: TextStyle(fontSize: 15, color: widget.themeExt.secondaryText, height: 1.6),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefinedVersion() {
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
                Icon(Icons.copy_outlined, size: 18, color: widget.themeExt.secondaryText),
                const SizedBox(width: 16),
                Icon(Icons.refresh, size: 18, color: widget.themeExt.secondaryText),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFC026D3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC026D3).withValues(alpha: 0.2)),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface, height: 1.6),
              children: [
                const TextSpan(text: '"I\'m writing to '),
                _buildHighlightedText('request'),
                const TextSpan(text: ' a meeting next week to '),
                _buildHighlightedText('discuss'),
                const TextSpan(text: ' the project\'s progress. I believe there are several '),
                _buildHighlightedText('critical issues'),
                const TextSpan(text: ' that require our immediate attention."'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InlineSpan _buildHighlightedText(String text) {
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

  Widget _buildToneSelectors() {
    final tones = ['PROFESSIONAL', 'CASUAL', 'CONCISE', 'ACADEMIC', 'TECHNICAL', 'CREATIVE'];
    return ScrollConfiguration(
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
                      color: _selectedTone == tone ? const Color(0xFF2563EB) : widget.themeExt.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedTone == tone ? const Color(0xFF2563EB) : widget.themeExt.borderColor,
                      ),
                    ),
                    child: Text(
                      tone,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedTone == tone ? Colors.white : widget.themeExt.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefineButton() {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.auto_fix_high, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Text(
            'REFINE TEXT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefinementScoreCard(ColorScheme colorScheme) {
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'IMPROVED',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '+24%',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          _buildScoreMetric('CLARITY', 0.92, const Color(0xFF2563EB)),
          const SizedBox(height: 16),
          _buildScoreMetric('TONE', 0.88, const Color(0xFFC026D3)),
          const SizedBox(height: 16),
          _buildScoreMetric('VOCABULARY', 0.85, const Color(0xFF3B82F6)),
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
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.themeExt.secondaryText),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
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

  Widget _buildKeyImprovementsCard(ColorScheme colorScheme) {
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
          _buildImprovementItem(
            'STRONGER VERBS',
            'Replaced "want to ask" with "request" for a more professional tone.',
          ),
          const SizedBox(height: 24),
          _buildImprovementItem(
            'IMPACTFUL NOUNS',
            'Swapped "some problems" for "critical issues" to emphasize importance.',
          ),
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
          decoration: const BoxDecoration(
            color: Color(0xFF22C55E),
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
