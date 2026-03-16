import 'package:eduprova/ui/pill_input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/rendering.dart';

class RoleplayScenario {
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String imageUrl;
  final IconData icon;
  final Color color;
  final String roleType;

  const RoleplayScenario({
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.imageUrl,
    required this.icon,
    required this.color,
    required this.roleType,
  });
}

class RoleplaySection extends StatefulWidget {
  final AppDesignExtension themeExt;
  final Function(RoleplayScenario, Map<String, dynamic>?) onStartPractice;
  const RoleplaySection({
    super.key,
    required this.themeExt,
    required this.onStartPractice,
  });

  @override
  State<RoleplaySection> createState() => _RoleplaySectionState();
}

class _RoleplaySectionState extends State<RoleplaySection> {
  int _selectedIndex = 0;
  final List<GlobalKey> _catKeys = List.generate(4, (index) => GlobalKey());
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;
  int? _hoverIndex;
  double _hoverLeft = 0;
  double _hoverWidth = 0;
  bool _isHovering = false;

  final List<RoleplayScenario> _scenarios = const [
    RoleplayScenario(
      title: 'HR Interview',
      description:
          'Practice behavioral questions, personality assessments, and culture-fit scenarios.',
      category: 'BUSINESS',
      difficulty: 'INTERMEDIATE',
      imageUrl: 'assets/images/roles/hr-interview.png',
      icon: Icons.groups,
      color: Color(0xFF0066FF),
      roleType: 'hr_interview',
    ),
    RoleplayScenario(
      title: 'Tech Job Interview',
      description:
          'Navigate complex technical questions and demonstrate soft skills.',
      category: 'BUSINESS',
      difficulty: 'ADVANCED',
      imageUrl: 'assets/images/roles/tech-job-interview.png',
      icon: Icons.computer,
      color: Color(0xFF0066FF),
      roleType: 'tech_interview',
    ),
    RoleplayScenario(
      title: 'Business Meeting',
      description:
          'Practice presenting data, handling objections, and professional turn-taking.',
      category: 'BUSINESS',
      difficulty: 'INTERMEDIATE',
      imageUrl: 'assets/images/roles/business-meeting.png',
      icon: Icons.business_center,
      color: Color(0xFF0066FF),
      roleType: 'business_meeting',
    ),
    RoleplayScenario(
      title: 'Ordering at a Cafe',
      description:
          'Master daily interactions, from special requests to payment methods.',
      category: 'TRAVEL & DINING',
      difficulty: 'BEGINNER',
      imageUrl: 'assets/images/roles/ordering-at-a-cafe.png',
      icon: Icons.coffee,
      color: Color(0xFF059669),
      roleType: 'ordering_cafe',
    ),
    RoleplayScenario(
      title: 'Kyoto Street Market',
      description:
          'Engage in cultural exchange while navigating a bustling food market.',
      category: 'SOCIAL',
      difficulty: 'INTERMEDIATE',
      imageUrl: 'assets/images/roles/kyoto-street-market.png',
      icon: Icons.shopping_bag,
      color: Color(0xFF7C3AED),
      roleType: 'kyoto_market',
    ),
    RoleplayScenario(
      title: 'Retail Shopping',
      description:
          'Practice asking for sizes, colors, and understanding store return policies.',
      category: 'DAILY LIFE',
      difficulty: 'BEGINNER',
      imageUrl: 'assets/images/roles/retail-shopping.png',
      icon: Icons.shopping_cart,
      color: Color(0xFF7C3AED),
      roleType: 'retail_shopping',
    ),
    RoleplayScenario(
      title: 'Checking into a Hotel',
      description:
          'Confirm reservations, ask about amenities, and report room issues.',
      category: 'TRAVEL',
      difficulty: 'INTERMEDIATE',
      imageUrl: 'assets/images/roles/checking-into-a-hotel.png',
      icon: Icons.hotel,
      color: Color(0xFF059669),
      roleType: 'hotel_checkin',
    ),
    RoleplayScenario(
      title: 'First Introductions',
      description:
          'Break the ice at a mixer. Learn greeting etiquette and small talk basics.',
      category: 'SOCIAL',
      difficulty: 'BEGINNER',
      imageUrl: 'assets/images/roles/first-introductions.png',
      icon: Icons.face,
      color: Color(0xFF7C3AED),
      roleType: 'first_introductions',
    ),
    RoleplayScenario(
      title: "Doctor's Appointment",
      description:
          'Describing symptoms precisely and understanding medical advice/prescriptions.',
      category: 'ESSENTIAL',
      difficulty: 'ADVANCED',
      imageUrl: 'assets/images/roles/doctors-appointment.png',
      icon: Icons.medical_services,
      color: Color(0xFF7C3AED),
      roleType: 'doctor_appointment',
    ),
    RoleplayScenario(
      title: 'Custom Prompt',
      description:
          'Define your own scenario. Practice specific situations exactly how you want.',
      category: 'CUSTOM',
      difficulty: 'ANY',
      imageUrl: 'assets/images/roles/custom-prompt.png',
      icon: Icons.settings,
      color: Color(0xFF6B7280),
      roleType: 'custom',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  void _updateIndicator() {
    final key = _catKeys[_selectedIndex];
    final context = key.currentContext;
    if (context == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final RenderBox? stackBox = context
        .findAncestorRenderObjectOfType<RenderStack>();
    if (stackBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero, ancestor: stackBox);
    setState(() {
      _indicatorLeft = position.dx;
      _indicatorWidth = renderBox.size.width;
    });
  }

  void _onTabTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _updateIndicatorPosition();
  }

  void _updateIndicatorPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _catKeys[_selectedIndex];
      final context = key.currentContext;
      if (context != null) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final RenderBox stackBox = context
            .findAncestorRenderObjectOfType<RenderStack>()!;
        final position = box.localToGlobal(Offset.zero, ancestor: stackBox);
        setState(() {
          _indicatorLeft = position.dx;
          _indicatorWidth = box.size.width;
        });
      }
    });
  }

  void _onHover(int index) {
    if (_selectedIndex == index) {
      if (_isHovering) setState(() => _isHovering = false);
      return;
    }
    setState(() {
      _hoverIndex = index;
      _isHovering = true;
    });
    _updateHoverPosition();
  }

  void _updateHoverPosition() {
    if (_hoverIndex == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _catKeys[_hoverIndex!];
      final context = key.currentContext;
      if (context != null) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final stackBox = context.findAncestorRenderObjectOfType<RenderStack>()!;
        final position = box.localToGlobal(Offset.zero, ancestor: stackBox);
        setState(() {
          _hoverLeft = position.dx;
          _hoverWidth = box.size.width;
        });
      }
    });
  }

  List<RoleplayScenario> get _filteredScenarios {
    if (_selectedIndex == 0) return _scenarios;
    final category = switch (_selectedIndex) {
      1 => 'BUSINESS',
      2 => 'TRAVEL & DINING',
      3 => 'SOCIAL',
      _ => 'ALL',
    };

    return _scenarios.where((s) {
      if (category == 'TRAVEL & DINING') {
        return s.category == 'TRAVEL & DINING' || s.category == 'TRAVEL';
      }
      return s.category == category;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCENARIO LIBRARY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0066FF),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose Your Roleplay',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Immerse yourself in real-world English scenarios powered by advanced AI.',
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.themeExt.secondaryText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryTabs(),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _filteredScenarios.length,
            itemBuilder: (context, index) {
              return _buildScenarioCard(_filteredScenarios[index]);
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      'All Scenarios',
      'Business',
      'Travel & Dining',
      'Social',
    ];
    return SizedBox(
      height: 54,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Hover Indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              left: _hoverLeft,
              width: _hoverWidth,
              height: 48,
              top: 3,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHovering ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            // Sliding Active Indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: _indicatorLeft,
              width: _indicatorWidth,
              height: 48,
              top: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                for (var (i, cat) in categories.indexed)
                  _buildCategoryChip(cat, i),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, int index) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: MouseRegion(
        key: _catKeys[index],
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _onHover(index),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: () {
            _onTabTap(index);
            setState(() => _isHovering = false);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                if (label == 'All Scenarios')
                  Icon(
                    Icons.grid_view_rounded,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : widget.themeExt.secondaryText,
                  ),
                if (label == 'Business')
                  Icon(
                    Icons.business_center,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : widget.themeExt.secondaryText,
                  ),
                if (label == 'Travel & Dining')
                  Icon(
                    Icons.restaurant,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : widget.themeExt.secondaryText,
                  ),
                if (label == 'Social')
                  Icon(
                    Icons.people_outline,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : widget.themeExt.secondaryText,
                  ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : widget.themeExt.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioCard(RoleplayScenario scenario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: widget.themeExt.borderColor),
        boxShadow: [
          BoxShadow(
            color: widget.themeExt.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                scenario.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bar_chart,
                        size: 14,
                        color: Color(0xFF0066FF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        scenario.difficulty,
                        style: const TextStyle(
                          color: Color(0xFF0066FF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      scenario.icon,
                      size: 16,
                      color: const Color(0xFF0066FF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      scenario.category,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0066FF),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  scenario.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  scenario.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.themeExt.secondaryText,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStartButton(scenario),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleStart(RoleplayScenario scenario) {
    if (scenario.roleType == 'hr_interview' ||
        scenario.roleType == 'tech_interview' ||
        scenario.roleType == 'custom') {
      _showConfigDialog(scenario);
    } else {
      widget.onStartPractice(scenario, null);
    }
  }

  void _showConfigDialog(RoleplayScenario scenario) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ConfigDialog(
        scenario: scenario,
        themeExt: widget.themeExt,
        onConfirm: (config) {
          Navigator.pop(context);
          widget.onStartPractice(scenario, config);
        },
      ),
    );
  }

  Widget _buildStartButton(RoleplayScenario scenario) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleStart(scenario),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0066FF), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Start Practice',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.play_circle_fill, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigDialog extends StatefulWidget {
  final RoleplayScenario scenario;
  final AppDesignExtension themeExt;
  final Function(Map<String, dynamic>) onConfirm;

  const _ConfigDialog({
    required this.scenario,
    required this.themeExt,
    required this.onConfirm,
  });

  @override
  State<_ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<_ConfigDialog> {
  // HR Interview fields
  String _experienceLevel = 'Junior (0-2 years)';
  String _companyType = 'Tech Startup';

  // Tech Interview fields
  final TextEditingController _jobTitleController = TextEditingController();
  final List<String> _selectedTech = [];
  String _seniority = 'Mid-level';

  // Custom Prompt fields
  final TextEditingController _customPromptController = TextEditingController();

  @override
  void dispose() {
    _jobTitleController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: .zero,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        constraints: const BoxConstraints(maxWidth: 550),
        decoration: BoxDecoration(
          color: widget.themeExt.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: widget.themeExt.borderColor),
          boxShadow: [
            BoxShadow(
              color: widget.themeExt.shadowColor,
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(colorScheme),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.scenario.roleType == 'hr_interview')
                      _buildHRFields(colorScheme),
                    if (widget.scenario.roleType == 'tech_interview')
                      _buildTechFields(colorScheme),
                    if (widget.scenario.roleType == 'custom')
                      _buildCustomFields(colorScheme),
                    const SizedBox(height: 32),
                    _buildConfirmButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.scenario.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(widget.scenario.icon, color: widget.scenario.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interview Setup',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.scenario.color,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  widget.scenario.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: widget.themeExt.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildHRFields(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Experience Level'),
        _buildDropdown(
          value: _experienceLevel,
          items: [
            'Junior (0-2 years)',
            'Mid-level (3-5 years)',
            'Senior (5+ years)',
            'Executive/Lead',
          ],
          onChanged: (val) => setState(() => _experienceLevel = val!),
        ),
        const SizedBox(height: 20),
        _buildLabel('Company Type'),
        _buildDropdown(
          value: _companyType,
          items: [
            'Tech Startup',
            'SME (Small/Medium)',
            'MNC / Large Enterprise',
            'Fortune 500',
          ],
          onChanged: (val) => setState(() => _companyType = val!),
        ),
      ],
    );
  }

  Widget _buildTechFields(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Role/Job Title'),
        _buildTextField(_jobTitleController, 'e.g. Frontend Engineer'),
        const SizedBox(height: 20),
        _buildLabel('Target Seniority'),
        _buildDropdown(
          value: _seniority,
          items: ['Junior', 'Mid-level', 'Senior', 'Staff/Architect'],
          onChanged: (val) => setState(() => _seniority = val!),
        ),
        const SizedBox(height: 20),
        _buildLabel('Tech Stack Specialties'),
        PillInput(
          initialValues: _selectedTech,
          onChanged: (pills) {
            _selectedTech.clear();
            _selectedTech.addAll(pills);
          },
          placeholder: 'Enter skill (e.g. Flutter, GraphQL)',
          color: widget.scenario.color,
        ),
      ],
    );
  }

  Widget _buildCustomFields(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Describe your roleplay scenario'),
        _buildTextField(
          _customPromptController,
          'e.g. I am a customer complaining about a delayed flight at the airport check-in counter...',
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: widget.themeExt.secondaryText,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: widget.themeExt.secondaryText.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: widget.themeExt.borderColor.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: widget.themeExt.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: widget.themeExt.borderColor),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: widget.themeExt.borderColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.themeExt.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: widget.themeExt.secondaryText,
          ),
          dropdownColor: widget.themeExt.cardColor,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () {
        Map<String, dynamic> config = {};
        if (widget.scenario.roleType == 'hr_interview') {
          config = {
            'experienceLevel': _experienceLevel,
            'companyType': _companyType,
          };
        } else if (widget.scenario.roleType == 'tech_interview') {
          config = {
            'jobTitle': _jobTitleController.text,
            'techStack': _selectedTech,
            'seniorityLevel': _seniority,
          };
        } else if (widget.scenario.roleType == 'custom') {
          config = {'customPrompt': _customPromptController.text};
        }
        widget.onConfirm(config);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.scenario.color,
              widget.scenario.color.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.scenario.color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Confirm & Setup',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
