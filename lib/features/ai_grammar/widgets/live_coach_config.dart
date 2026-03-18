import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveCoachConfigSection extends StatefulWidget {
  final AppDesignExtension themeExt;
  final VoidCallback onStart;

  const LiveCoachConfigSection({
    super.key,
    required this.themeExt,
    required this.onStart,
  });

  @override
  State<LiveCoachConfigSection> createState() => _LiveCoachConfigSectionState();
}

class _LiveCoachConfigSectionState extends State<LiveCoachConfigSection> {
  String _selectedFocus = 'General Fluency';
  String _selectedDifficulty = 'Intermediate';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Color(0xFF10B981),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI LIVE COACH',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Session Setup',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Configure your live coaching session. The AI Coach will adapt its feedback and conversational style based on your choices.',
            style: TextStyle(
              fontSize: 16,
              color: widget.themeExt.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildConfigCard(
            title: 'Focus Area',
            icon: Icons.track_changes,
            child: _buildDropdown(
              value: _selectedFocus,
              items: [
                'General Fluency',
                'Pronunciation',
                'Vocabulary Building',
                'Business English',
              ],
              onChanged: (val) => setState(() => _selectedFocus = val!),
            ),
          ),
          const SizedBox(height: 24),
          _buildConfigCard(
            title: 'Difficulty Level',
            icon: Icons.bar_chart,
            child: _buildDropdown(
              value: _selectedDifficulty,
              items: ['Beginner', 'Intermediate', 'Advanced', 'Native-like'],
              onChanged: (val) => setState(() => _selectedDifficulty = val!),
            ),
          ),
          const SizedBox(height: 48),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildConfigCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.themeExt.borderColor),
        boxShadow: [
          BoxShadow(
            color: widget.themeExt.shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: widget.themeExt.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.themeExt.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: widget.themeExt.cardColor,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: widget.themeExt.secondaryText,
          ),
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onStart,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Start Live Coaching',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.mic, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
