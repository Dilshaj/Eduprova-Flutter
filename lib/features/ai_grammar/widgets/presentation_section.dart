import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';

class PresentationSection extends StatefulWidget {
  final AppDesignExtension themeExt;
  final VoidCallback onBack;

  const PresentationSection({
    super.key,
    required this.themeExt,
    required this.onBack,
  });

  @override
  State<PresentationSection> createState() => _PresentationSectionState();
}

class _PresentationSectionState extends State<PresentationSection> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          _buildSlideInfoBar(colorScheme),
          const SizedBox(height: 20),
          _buildMainSlide(),
          const SizedBox(height: 20),
          _buildSpeakerNotes(colorScheme),
          const SizedBox(height: 16),
          _buildSessionTimer(colorScheme),
          const SizedBox(height: 16),
          _buildPacingMeter(colorScheme),
          const SizedBox(height: 16),
          _buildCheckpoints(colorScheme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSlideInfoBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(30),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.copy,
                  size: 14,
                  color: widget.themeExt.secondaryText,
                ),
                const SizedBox(width: 6),
                Text(
                  'SLIDE 04 / 12',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Q3 Strategic Pillars',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(
              Icons.description_outlined,
              color: widget.themeExt.secondaryText,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(
              Icons.settings_outlined,
              color: widget.themeExt.secondaryText,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSlide() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=1000',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operational Excellence',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Streamlining workflows for maximum efficiency.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerNotes(ColorScheme colorScheme) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPEAKER NOTES',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.themeExt.secondaryText,
                  letterSpacing: 1.1,
                ),
              ),
              const Text(
                'EDIT SCRIPT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF475569),
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
              children: [
                const TextSpan(
                  text:
                      '"Now, moving on to our third pillar: Operational Excellence. This isn\'t just about cutting costs; it\'s about ',
                ),
                TextSpan(
                  text: 'reimagining our core workflows',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    fontStyle: FontStyle.normal,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(
                      0xFFC026D3,
                    ).withValues(alpha: 0.3),
                    decorationThickness: 4,
                  ),
                ),
                const TextSpan(text: ' to empower our teams..."'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTimer(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF0066FF).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SESSION TIMER',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0066FF),
                  letterSpacing: 1.1,
                ),
              ),
              const Icon(Icons.access_time, size: 18, color: Color(0xFF0066FF)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '08:42',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ON TRACK • TARGET 12:00',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPacingMeter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.themeExt.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PACING METER',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.themeExt.secondaryText,
                  letterSpacing: 1.1,
                ),
              ),
              const Icon(Icons.show_chart, size: 20, color: Color(0xFF9333EA)),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPacingLabel('SLOW'),
              _buildPacingLabel('PERFECT', isActive: true),
              _buildPacingLabel('FAST'),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                height: 16,
                width: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF9333EA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                height: 8,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF9333EA).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '142 WORDS PER MINUTE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.themeExt.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacingLabel(String text, {bool isActive = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isActive ? const Color(0xFF9333EA) : const Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCheckpoints(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.themeExt.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY CHECKPOINTS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.themeExt.secondaryText,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          _buildCheckpointItem('Introduction', isCompleted: true),
          _buildCheckpointDivider(),
          _buildCheckpointItem('Market Analysis', isCompleted: true),
          _buildCheckpointDivider(),
          _buildCheckpointItem('Q3 Strategy', isActive: true),
          _buildCheckpointDivider(),
          _buildCheckpointItem('Financial Outlook', isPending: true),
        ],
      ),
    );
  }

  Widget _buildCheckpointItem(
    String title, {
    bool isCompleted = false,
    bool isActive = false,
    bool isPending = false,
  }) {
    Color textColor = widget
        .themeExt
        .secondaryText; // Just use secondary if not trying to use context
    if (isCompleted) textColor = const Color(0xFF94A3B8);
    if (isPending) textColor = const Color(0xFFCBD5E1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20)
          else if (isActive)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0066FF).withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.circle,
                color: Color(0xFF0066FF),
                size: 12,
              ),
            )
          else
            const Icon(
              Icons.circle_outlined,
              color: Color(0xFFE2E8F0),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildCheckpointDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: widget.themeExt.borderColor, height: 1),
    );
  }
}
