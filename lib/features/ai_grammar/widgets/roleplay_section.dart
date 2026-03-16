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

  const RoleplayScenario({
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.imageUrl,
    required this.icon,
    required this.color,
  });
}

class RoleplaySection extends StatefulWidget {
  final AppDesignExtension themeExt;
  final Function(RoleplayScenario) onStartPractice;
  const RoleplaySection({super.key, required this.themeExt, required this.onStartPractice});

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
      title: 'Business Meeting',
      description: 'Practice presenting data, handling objections, and professional turn-taking in a corporate setting.',
      category: 'BUSINESS',
      difficulty: 'INTERMEDIATE (B2)',
      imageUrl: 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?q=80&w=500',
      icon: Icons.business_center,
      color: Color(0xFF0066FF),
    ),
    RoleplayScenario(
      title: 'Ordering at a Cafe',
      description: 'Master daily interactions, from special requests to payment methods in a casual environment.',
      category: 'TRAVEL & DINING',
      difficulty: 'BEGINNER (A2)',
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=500',
      icon: Icons.restaurant,
      color: Color(0xFF059669),
    ),
    RoleplayScenario(
      title: 'Tech Job Interview',
      description: 'Navigate complex technical questions and demonstrate soft skills for your dream role.',
      category: 'BUSINESS',
      difficulty: 'ADVANCED (C1)',
      imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=500',
      icon: Icons.computer,
      color: Color(0xFF0066FF),
    ),
    RoleplayScenario(
      title: 'Kyoto Street Market',
      description: 'Engage in cultural exchange while navigating a bustling food market and talking to vendors.',
      category: 'SOCIAL',
      difficulty: 'INTERMEDIATE (B1)',
      imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=500',
      icon: Icons.chat_bubble_outline,
      color: Color(0xFF7C3AED),
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
    final RenderBox? stackBox = context.findAncestorRenderObjectOfType<RenderStack>();
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
        final RenderBox stackBox = context.findAncestorRenderObjectOfType<RenderStack>()!;
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
          itemCount: _scenarios.length,
          itemBuilder: (context, index) {
            return _buildScenarioCard(_scenarios[index]);
          },
        ),
        const SizedBox(height: 40),
      ],
    ),
  );
}

  Widget _buildCategoryTabs() {
    final categories = ['All Scenarios', 'Business', 'Travel & Dining', 'Social'];
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
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                if (label == 'All Scenarios') 
                  Icon(Icons.grid_view_rounded, size: 18, color: isSelected ? Colors.white : widget.themeExt.secondaryText),
                if (label == 'Business') 
                  Icon(Icons.business_center, size: 18, color: isSelected ? Colors.white : widget.themeExt.secondaryText),
                if (label == 'Travel & Dining') 
                  Icon(Icons.restaurant, size: 18, color: isSelected ? Colors.white : widget.themeExt.secondaryText),
                if (label == 'Social') 
                  Icon(Icons.people_outline, size: 18, color: isSelected ? Colors.white : widget.themeExt.secondaryText),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : widget.themeExt.secondaryText,
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
              Image.network(
                scenario.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF0066FF).withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bar_chart, size: 14, color: Color(0xFF0066FF)),
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
                    Icon(scenario.icon, size: 16, color: const Color(0xFF0066FF)),
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

  Widget _buildStartButton(RoleplayScenario scenario) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onStartPractice(scenario),
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
