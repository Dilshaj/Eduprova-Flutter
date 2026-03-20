import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveCoachConfigSection extends StatefulWidget {
  final AppDesignExtension themeExt;
  final void Function(String mode, String topic) onStart;

  const LiveCoachConfigSection({
    super.key,
    required this.themeExt,
    required this.onStart,
  });

  @override
  State<LiveCoachConfigSection> createState() => _LiveCoachConfigSectionState();
}

class _LiveCoachConfigSectionState extends State<LiveCoachConfigSection> {
  String _selectedMode = 'free_talk';
  String _selectedTopic = '';

  final Map<String, List<String>> _topics = {
    'grammar': [
      'Tenses',
      'Articles',
      'Prepositions',
      'Subject-Verb Agreement',
      'Direct/Indirect Speech',
    ],
    'shadowing': [
      'Everyday Phrases',
      'Business Idioms',
      'Tech Jargon',
      'Travel Essentials',
    ],
    'roleplay': [
      'HR Interviewer',
      'Tech Startup Founder',
      'Angry Customer',
      'Cafe Barista',
    ],
  };

  final List<({String id, String label, String description, IconData icon})>
  _modes = [
    (
      id: 'free_talk',
      label: 'Free Talk',
      description: 'Unstructured conversation with gentle corrections.',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    (
      id: 'grammar',
      label: 'Grammar Practice',
      description: 'Targeted practice on specific grammar rules.',
      icon: Icons.book_outlined,
    ),
    (
      id: 'shadowing',
      label: 'Shadowing',
      description: 'Listen and repeat to improve pronunciation.',
      icon: Icons.settings_voice_outlined,
    ),
    (
      id: 'roleplay',
      label: 'Role Play',
      description: 'Act out specific scenarios like interviews or cafes.',
      icon: Icons.theater_comedy_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: .all(24.0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Container(
                padding: .all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: .circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF3B82F6),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'AI LIVE COACH',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B82F6),
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
            'Select how you want to interact with Prova today. The AI Coach will adapt its feedback and conversational style based on your choices.',
            style: TextStyle(
              fontSize: 16,
              color: widget.themeExt.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'PRACTICE MODE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: widget.themeExt.secondaryText,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          ..._modes.map((mode) => _buildModeCard(mode)),
          if (_selectedMode != 'free_talk') ...[
            const SizedBox(height: 32),
            Text(
              'SELECT FOCUS TOPIC',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: widget.themeExt.secondaryText,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            _buildTopicGrid(),
          ],
          const SizedBox(height: 48),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    ({String id, String label, String description, IconData icon}) mode,
  ) {
    final isSelected = _selectedMode == mode.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode.id;
          if (mode.id != 'free_talk') {
            _selectedTopic = _topics[mode.id]!.first;
          } else {
            _selectedTopic = '';
          }
        });
      },
      child: Container(
        margin: .only(bottom: 16),
        padding: .all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withValues(alpha: 0.05)
              : widget.themeExt.cardColor,
          borderRadius: .circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6).withValues(alpha: 0.5)
                : widget.themeExt.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: .all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                    : widget.themeExt.scaffoldBackgroundColor,
                borderRadius: .circular(16),
              ),
              child: Icon(
                mode.icon,
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : widget.themeExt.secondaryText,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    mode.label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.themeExt.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF3B82F6)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicGrid() {
    final topics = _topics[_selectedMode] ?? [];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: topics.map((topic) {
        final isSelected = _selectedTopic == topic;
        return GestureDetector(
          onTap: () => setState(() => _selectedTopic = topic),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: .symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              borderRadius: .circular(30),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : widget.themeExt.borderColor,
              ),
            ),
            child: Text(
              topic,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : widget.themeExt.secondaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onStart(_selectedMode, _selectedTopic),
        child: Container(
          width: double.infinity,
          padding: .symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
            borderRadius: .circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: .center,
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
