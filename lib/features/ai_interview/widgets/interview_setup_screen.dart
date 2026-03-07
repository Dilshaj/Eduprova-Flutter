import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../interview_bot/interview_bot_screen.dart';
import 'ai_theme.dart';
import '../core/repositories/interview_repository.dart';

class PracticePreviewPage extends ConsumerStatefulWidget {
  const PracticePreviewPage({super.key});

  @override
  ConsumerState<PracticePreviewPage> createState() =>
      _PracticePreviewPageState();
}

class _PracticePreviewPageState extends ConsumerState<PracticePreviewPage> {
  double _experienceYears = 5;
  bool _isStarting = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  final List<String> _allAvailableSkills = [
    'React',
    'Node.js',
    'Python',
    'System Design',
    'Vue',
    'Angular',
    'Java',
    'C++',
    'Go',
    'Rust',
    'Flutter',
    'Dart',
    'AWS',
    'Docker',
    'Kubernetes',
    'SQL',
    'MongoDB',
    'PostgreSQL',
    'TypeScript',
    'JavaScript',
    'Kotlin',
    'Swift',
    'C#',
    'PHP',
    'Ruby',
    'HTML',
    'CSS',
  ];
  final List<String> _selectedSkills = ['React', 'System Design'];
  List<String> _filteredSkills = [];

  String _selectedDuration = '30M';
  String _selectedVoice = 'FEM';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocus.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocus.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (_searchFocus.hasFocus) {
      _updateFilteredSkills();
    } else {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _filteredSkills = [];
          });
        }
      });
    }
  }

  void _onSearchChanged() {
    if (_searchFocus.hasFocus) {
      _updateFilteredSkills();
    }
  }

  void _updateFilteredSkills() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSkills = [];
      } else {
        _filteredSkills = _allAvailableSkills
            .where(
              (skill) =>
                  skill.toLowerCase().contains(query) &&
                  !_selectedSkills.contains(skill),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Stack(
        children: [
          const BlurredBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _buildAIChip(),
                          const SizedBox(height: 24),
                          _buildTitles(),
                          const SizedBox(height: 16),
                          _buildSubtitles(),
                          const SizedBox(height: 32),
                          _buildCard(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: t.iconBack, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: t.iconBack,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAIChip() {
    final t = AiTheme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: t.chipBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.chipBorder, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF2962FF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI INTELLIGENCE ENGINE',
                style: TextStyle(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitles() {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Session',
            style: TextStyle(
              color: t.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Preview Details',
            style: TextStyle(
              color: const Color(0xFF2962FF),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitles() {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Customize your AI interview environment for the best experience.',
        style: TextStyle(
          color: t.textMuted,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCard() {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: t.cardBorder, width: 1),
          boxShadow: t.cardShadow,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.terminal_rounded, 'SKILLS TO FOCUS'),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildChips(),
            const SizedBox(height: 32),
            _buildSectionHeader(Icons.history_rounded, 'EXPERIENCE LEVEL'),
            const SizedBox(height: 16),
            _buildSlider(),
            const SizedBox(height: 32),
            _buildSectionHeader(Icons.tune_rounded, 'PREFERENCES'),
            const SizedBox(height: 16),
            _buildPreferencesRows(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    final t = AiTheme.of(context);
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2962FF), size: 18),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: t.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final t = AiTheme.of(context);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: t.scaffoldBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _searchFocus.hasFocus
                  ? const Color(0xFF2962FF)
                  : t.cardBorder,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search skills (e.g. Flutter, React)',
              hintStyle: TextStyle(
                color: t.textMuted.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _searchFocus.hasFocus
                    ? const Color(0xFF2962FF)
                    : t.textMuted,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (_filteredSkills.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSkills.length,
              itemBuilder: (context, index) {
                final skill = _filteredSkills[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (!_selectedSkills.contains(skill)) {
                        _selectedSkills.add(skill);
                      }
                      _searchController.clear();
                      _searchFocus.unfocus();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._selectedSkills.map((s) => _buildTechChip(s)),
        _buildAddSkillChip(),
      ],
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2962FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2962FF).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2962FF),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedSkills.remove(label);
              });
            },
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFF2962FF),
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSkillChip() {
    final t = AiTheme.of(context);
    return GestureDetector(
      onTap: () {
        _searchFocus.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: t.scaffoldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.cardBorder, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: t.textMuted, size: 16),
            const SizedBox(width: 4),
            Text(
              'Add New',
              style: TextStyle(
                color: t.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    final t = AiTheme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Professional Experience',
              style: TextStyle(
                color: t.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_experienceYears.toInt()} Years',
              style: const TextStyle(
                color: Color(0xFF2962FF),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF2962FF),
            inactiveTrackColor: t.scaffoldBg,
            thumbColor: const Color(0xFF2962FF),
            overlayColor: const Color(0xFF2962FF).withValues(alpha: 0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: _experienceYears,
            min: 0,
            max: 15,
            onChanged: (v) {
              setState(() => _experienceYears = v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesRows() {
    return Row(
      children: [
        Expanded(child: _buildToggleOption('DUR', 'Duration')),
        const SizedBox(width: 16),
        Expanded(child: _buildToggleOption('VOI', 'Voice')),
      ],
    );
  }

  Widget _buildToggleOption(String type, String label) {
    final t = AiTheme.of(context);
    final isDur = type == 'DUR';
    final options = isDur ? ['30M', '60M'] : ['ML', 'FL'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: t.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: t.scaffoldBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: options.map((opt) {
              final isSelected = isDur
                  ? _selectedDuration == opt
                  : _selectedVoice == (opt == 'ML' ? 'MAL' : 'FEM');
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isDur) {
                        _selectedDuration = opt;
                      } else {
                        _selectedVoice = opt == 'ML' ? 'MAL' : 'FEM';
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? t.cardBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected ? t.cardShadow : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2962FF)
                            : t.textMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _startInterview() async {
    setState(() => _isStarting = true);
    try {
      final repo = InterviewRepository();
      final result = await repo.createSession(
        type: 'normal',
        config: {
          'duration': _selectedDuration == '30M' ? 30 : 60,
          'techStack': _selectedSkills,
          'experience': _experienceYears.toInt(),
          'voice': _selectedVoice.toLowerCase(),
        },
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InterviewBotPage(
              sessionId: result.sessionId,
              questions: result.questions,
              role: _selectedSkills.isNotEmpty
                  ? _selectedSkills.first
                  : 'Technical',
              duration: _selectedDuration,
              voice: _selectedVoice == 'FEM' ? 'FEMALE' : 'MALE',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start: $e')));
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Skeletonizer(
        enabled: _isStarting,
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isStarting ? null : _startInterview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2962FF),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF2962FF).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'START INTERVIEW',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class BlurredBackground extends StatelessWidget {
  const BlurredBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        return Stack(
          children: [
            Positioned(
              top: -height * 0.1,
              left: -width * 0.1,
              child: Container(
                width: width * 0.7,
                height: width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              top: height * 0.2,
              right: -width * 0.2,
              child: Container(
                width: width * 0.8,
                height: width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.1,
              left: -width * 0.2,
              child: Container(
                width: width * 0.8,
                height: width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -height * 0.1,
              right: -width * 0.1,
              child: Container(
                width: width * 0.7,
                height: width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA855F7).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}
