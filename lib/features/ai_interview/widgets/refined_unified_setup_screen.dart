import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../interview_bot/interview_bot_screen.dart';
import 'ai_theme.dart';
import '../core/repositories/interview_repository.dart';

class RefinedUnifiedInterviewSetupPage extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const RefinedUnifiedInterviewSetupPage({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<RefinedUnifiedInterviewSetupPage> createState() =>
      _RefinedUnifiedInterviewSetupPageState();
}

class _RefinedUnifiedInterviewSetupPageState
    extends ConsumerState<RefinedUnifiedInterviewSetupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Shared State
  String _selectedDuration = '30M';
  String _selectedVoice = 'FEM';
  bool _isStarting = false;

  // Quick Practice State
  double _experienceYears = 5;
  final TextEditingController _skillSearchController = TextEditingController();
  final FocusNode _skillSearchFocus = FocusNode();
  final List<String> _selectedSkills = ['React'];
  List<String> _filteredSkills = [];

  // Resume Based State
  PlatformFile? _selectedFile;
  final TextEditingController _jobRoleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() => setState(() {}));
    _skillSearchController.addListener(_onSearchChanged);
    _skillSearchFocus.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _skillSearchController.dispose();
    _skillSearchFocus.dispose();
    _jobRoleController.dispose();
    _jobDescriptionController.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (_skillSearchFocus.hasFocus) {
      _updateFilteredSkills();
    } else {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _filteredSkills = []);
      });
    }
  }

  void _onSearchChanged() {
    if (_skillSearchFocus.hasFocus) _updateFilteredSkills();
  }

  void _updateFilteredSkills() {
    final query = _skillSearchController.text.trim().toLowerCase();
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

  Future<void> _pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: .custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null) setState(() => _selectedFile = result.files.first);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _startInterview() async {
    final isResumeMode = _tabController.index == 1;
    if (isResumeMode && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your resume first')),
      );
      return;
    }

    setState(() => _isStarting = true);
    try {
      final repo = InterviewRepository();
      final config = {
        'duration': _selectedDuration == '30M' ? 30 : 60,
        'voice': _selectedVoice.toLowerCase(),
      };

      if (isResumeMode) {
        config.addAll({
          'jobRole': _jobRoleController.text,
          'jobDescription': _jobDescriptionController.text,
          'resumeName': _selectedFile!.name,
        });
      } else {
        config.addAll({
          'techStack': _selectedSkills,
          'experience': _experienceYears.toInt(),
        });
      }

      final result = await repo.createSession(
        type: isResumeMode ? 'resume' : 'normal',
        config: config,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InterviewBotPage(
              sessionId: result.sessionId,
              questions: result.questions,
              role: isResumeMode
                  ? (_jobRoleController.text.isNotEmpty
                        ? _jobRoleController.text
                        : 'Resume Based')
                  : (_selectedSkills.isNotEmpty
                        ? _selectedSkills.first
                        : 'Technical'),
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

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Stack(
        children: [
          const BlurredBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: .stretch,
                        children: [
                          const SizedBox(height: 16),
                          _buildStaticHeader(t),
                          const SizedBox(height: 32),
                          _buildMainConfigCard(t),
                          const SizedBox(height: 24),
                          _buildSharedOptionsCard(t),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomActions(),
              ],
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
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: .circular(8),
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
        ],
      ),
    );
  }

  Widget _buildStaticHeader(AiTheme t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: t.chipBg,
              borderRadius: .circular(24),
              border: .all(color: t.chipBorder, width: 1.5),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2962FF),
                    shape: .circle,
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
          const SizedBox(height: 24),
          Text(
            'Practice Session',
            style: TextStyle(
              color: t.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your AI interview environment for the best experience.',
            style: TextStyle(
              color: t.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainConfigCard(AiTheme t) {
    final isResumeMode = _tabController.index == 1;
    final color = isResumeMode
        ? const Color(0xFF3B82F6)
        : const Color(0xFF2962FF);

    return Container(
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: .circular(32),
        border: .all(color: t.cardBorder, width: 1),
        boxShadow: t.cardShadow,
      ),
      child: Column(
        children: [
          // Local TabBar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: t.scaffoldBg,
                borderRadius: .circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: color,
                  borderRadius: .circular(10),
                ),
                indicatorSize: .tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: t.textMuted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Quick Practice'),
                  Tab(text: 'Resume Based'),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: isResumeMode
                  ? _buildResumeContent(t, color)
                  : _buildQuickContent(t, color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContent(AiTheme t, Color color) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        _buildSectionHeader(
          t,
          Icons.terminal_rounded,
          'SKILLS TO FOCUS',
          color,
        ),
        const SizedBox(height: 16),
        _buildSearchBar(t, color),
        const SizedBox(height: 16),
        _buildChips(t, color),
        const SizedBox(height: 32),
        _buildSectionHeader(
          t,
          Icons.history_rounded,
          'EXPERIENCE LEVEL',
          color,
        ),
        const SizedBox(height: 16),
        _buildSlider(t, color),
      ],
    );
  }

  Widget _buildResumeContent(AiTheme t, Color color) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        _buildSectionHeader(
          t,
          Icons.upload_file_rounded,
          'UPLOAD RESUME',
          color,
        ),
        const SizedBox(height: 16),
        _buildUploadArea(t, color),
        const SizedBox(height: 32),
        _buildSectionHeader(
          t,
          Icons.work_outline_rounded,
          'TARGET ROLE',
          color,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          t,
          controller: _jobRoleController,
          hint: 'e.g. Senior Frontend Engineer',
          icon: Icons.person_search_outlined,
        ),
        const SizedBox(height: 32),
        _buildSectionHeader(
          t,
          Icons.description_outlined,
          'JOB DESCRIPTION (OPTIONAL)',
          color,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          t,
          controller: _jobDescriptionController,
          hint: 'Paste job description here...',
          icon: Icons.notes_rounded,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSharedOptionsCard(AiTheme t) {
    final color = _tabController.index == 1
        ? const Color(0xFF3B82F6)
        : const Color(0xFF2962FF);
    return Container(
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: .circular(24),
        border: .all(color: t.cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildSectionHeader(
            t,
            Icons.tune_rounded,
            'GENERAL PREFERENCES',
            color,
          ),
          const SizedBox(height: 20),
          _buildPreferencesRows(t, color),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    AiTheme t,
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: t.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  // --- Components ---

  Widget _buildSearchBar(AiTheme t, Color color) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: t.scaffoldBg,
            borderRadius: .circular(16),
            border: .all(
              color: _skillSearchFocus.hasFocus ? color : t.cardBorder,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _skillSearchController,
            focusNode: _skillSearchFocus,
            style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search skills...',
              hintStyle: TextStyle(
                color: t.textMuted.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _skillSearchFocus.hasFocus ? color : t.textMuted,
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
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: .circular(16),
              border: .all(color: t.cardBorder),
            ),
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSkills.length,
              itemBuilder: (context, index) {
                final skill = _filteredSkills[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    skill,
                    style: TextStyle(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (!_selectedSkills.contains(skill))
                        _selectedSkills.add(skill);
                      _skillSearchController.clear();
                      _skillSearchFocus.unfocus();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildChips(AiTheme t, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._selectedSkills.map((s) => _buildTechChip(t, s, color)),
        _buildAddSkillChip(t),
      ],
    );
  }

  Widget _buildTechChip(AiTheme t, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: .circular(10),
        border: .all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _selectedSkills.remove(label)),
            child: Icon(Icons.close_rounded, color: color, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSkillChip(AiTheme t) {
    return GestureDetector(
      onTap: () => _skillSearchFocus.requestFocus(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: t.scaffoldBg,
          borderRadius: .circular(10),
          border: .all(color: t.cardBorder),
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            Icon(Icons.add_rounded, color: t.textMuted, size: 14),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                color: t.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(AiTheme t, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              'Experience Level',
              style: TextStyle(
                color: t.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              '${_experienceYears.toInt()} Years',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: t.scaffoldBg,
            thumbColor: color,
            trackHeight: 6,
          ),
          child: Slider(
            value: _experienceYears,
            min: 0,
            max: 15,
            onChanged: (v) => setState(() => _experienceYears = v),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(AiTheme t, Color color) {
    final isSelected = _selectedFile != null;
    return GestureDetector(
      onTap: _pickResume,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : t.scaffoldBg,
          borderRadius: .circular(20),
          border: .all(
            color: isSelected ? color : t.cardBorder.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.cloud_upload_outlined,
              color: isSelected ? color : t.textMuted,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              isSelected ? _selectedFile!.name : 'Select Your Resume',
              textAlign: .center,
              style: TextStyle(
                color: isSelected ? t.textPrimary : t.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (!isSelected)
              const Text(
                'PDF, DOCX up to 10MB',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    AiTheme t, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: t.scaffoldBg,
        borderRadius: .circular(16),
        border: .all(color: t.cardBorder.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: t.textMuted.withValues(alpha: 0.5),
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: t.textMuted, size: 18),
          border: InputBorder.none,
          contentPadding: .symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPreferencesRows(AiTheme t, Color color) {
    return Row(
      children: [
        Expanded(child: _buildToggleOption(t, 'DUR', 'Duration', color)),
        const SizedBox(width: 16),
        Expanded(child: _buildToggleOption(t, 'VOI', 'Voice', color)),
      ],
    );
  }

  Widget _buildToggleOption(AiTheme t, String type, String label, Color color) {
    final isDur = type == 'DUR';
    final options = isDur ? ['30M', '60M'] : ['ML', 'FL'];
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: t.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: t.scaffoldBg,
            borderRadius: .circular(10),
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
                    padding: .symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? t.cardBg : Colors.transparent,
                      borderRadius: .circular(8),
                      boxShadow: isSelected ? t.cardShadow : null,
                    ),
                    alignment: .center,
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: isSelected ? color : t.textMuted,
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

  Widget _buildBottomActions() {
    final isResumeMode = _tabController.index == 1;
    final color = isResumeMode
        ? const Color(0xFF3B82F6)
        : const Color(0xFF2962FF);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _isStarting ? null : _startInterview,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: color.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: .circular(16)),
          ),
          child: _isStarting
              ? const SpinKitThreeBounce(color: Colors.white, size: 24)
              : Text(
                  isResumeMode ? 'ANALYZE & START' : 'START INTERVIEW',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        Positioned(
          top: -height * 0.1,
          left: -width * 0.1,
          child: Container(
            width: width * 0.7,
            height: width * 0.7,
            decoration: BoxDecoration(
              shape: .circle,
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
              shape: .circle,
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
              shape: .circle,
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
              shape: .circle,
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
  }
}
