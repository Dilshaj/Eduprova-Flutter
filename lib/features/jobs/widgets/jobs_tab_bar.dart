import 'package:eduprova/features/jobs/providers/job_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

class JobsTabBar extends ConsumerStatefulWidget {
  const JobsTabBar({super.key});

  @override
  ConsumerState<JobsTabBar> createState() => _JobsTabBarState();
}

class _JobsTabBarState extends ConsumerState<JobsTabBar> {
  final List<GlobalKey> _keys = List.generate(4, (_) => GlobalKey());
  final GlobalKey _stackKey = GlobalKey();
  
  double _activeLeft = 0;
  double _activeWidth = 0;
  double _hoverLeft = 0;
  double _hoverWidth = 0;
  bool _isHovered = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateActiveStyle(ref.read(jobsTabProvider));
      setState(() {
        _isInit = true;
      });
    });
  }

  void _updateActiveStyle(JobsTab activeTab) {
    if (!mounted) return;
    int index = JobsTab.values.indexOf(activeTab);
    if (index >= 0 && index < _keys.length) {
      final key = _keys[index];
      final stackContext = _stackKey.currentContext;
      if (key.currentContext != null && stackContext != null) {
        final box = key.currentContext!.findRenderObject() as RenderBox;
        final RenderBox parent = stackContext.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero, ancestor: parent);
        setState(() {
          _activeLeft = offset.dx;
          _activeWidth = box.size.width;
        });
      }
    }
  }

  void _updateHoverStyle(int? index) {
    if (index == null) {
      setState(() => _isHovered = false);
      return;
    }
    final key = _keys[index];
    final stackContext = _stackKey.currentContext;
    if (key.currentContext != null && stackContext != null) {
      final box = key.currentContext!.findRenderObject() as RenderBox;
      final RenderBox parent = stackContext.findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero, ancestor: parent);
      setState(() {
        _isHovered = true;
        _hoverLeft = offset.dx;
        _hoverWidth = box.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(jobsTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<JobsTab>(jobsTabProvider, (previous, next) {
      _updateActiveStyle(next);
    });

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.black.withValues(alpha: 0.25) 
          : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.08) 
            : Colors.white.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Stack(
            key: _stackKey,
            children: [
              // Hover Glow Pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left: _hoverLeft,
                top: 0,
                bottom: 0,
                width: _isHovered ? _hoverWidth : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // Active Pill with sliding animation
              if (_isInit)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  left: _activeLeft,
                  top: 0,
                  bottom: 0,
                  width: _activeWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3067FF), Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3067FF).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  ),
                ),

              // Nav Items
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TabItem(
                    key: _keys[0],
                    label: 'Recommended',
                    icon: Icons.grid_view_outlined,
                    isActive: activeTab == JobsTab.recommended,
                    onTap: () => ref.read(jobsTabProvider.notifier).update(JobsTab.recommended),
                    onHover: (hovering) => _updateHoverStyle(hovering ? 0 : null),
                  ),
                  _TabItem(
                    key: _keys[1],
                    label: 'My Applications',
                    icon: Icons.assignment_outlined,
                    isActive: activeTab == JobsTab.applications,
                    onTap: () => ref.read(jobsTabProvider.notifier).update(JobsTab.applications),
                    onHover: (hovering) => _updateHoverStyle(hovering ? 1 : null),
                  ),
                  _TabItem(
                    key: _keys[2],
                    label: 'Saved',
                    icon: Icons.bookmark_outline,
                    isActive: activeTab == JobsTab.saved,
                    onTap: () => ref.read(jobsTabProvider.notifier).update(JobsTab.saved),
                    onHover: (hovering) => _updateHoverStyle(hovering ? 2 : null),
                  ),
                  _TabItem(
                    key: _keys[3],
                    label: 'Posted Jobs',
                    icon: Icons.business_center_outlined,
                    isActive: activeTab == JobsTab.posted_jobs,
                    onTap: () => ref.read(jobsTabProvider.notifier).update(JobsTab.posted_jobs),
                    onHover: (hovering) => _updateHoverStyle(hovering ? 3 : null),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Function(bool) onHover;

  const _TabItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
