import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:eduprova/core/navigation/app_routes.dart';
import 'stories_provider.dart';

class StatusRow extends ConsumerWidget {
  const StatusRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(statusProfilesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return profilesAsync.when(
      data: (profiles) {
        final displayProfiles = profiles.isEmpty ? _getGreetingDummyStories() : profiles;
        return _buildStoriesCarousel(context, displayProfiles, isDark);
      },
      loading: () => _buildStoriesCarousel(
        context,
        _getGreetingDummyStories(),
        isDark,
        isLoading: true,
      ),
      error: (err, st) => const SizedBox.shrink(),
    );
  }

  Widget _buildStoriesCarousel(
    BuildContext context,
    List<StatusProfile> profiles,
    bool isDark, {
    bool isLoading = false,
  }) {
    return Container(
      height: 155, 
      margin: const EdgeInsets.symmetric(vertical: 0),
      child: Skeletonizer(
        enabled: isLoading,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: profiles.length + 1,
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            if (index == 0) return const _AddStoryCard();
            return _buildStatusCard(context, index - 1, profiles[index - 1], isDark);
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, int index, StatusProfile profile, bool isDark) {
    final hasUnseen = profile.hasUnseen;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.statusPager(index.toString())),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: hasUnseen
                  ? const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF8B5CF6), Color(0xFFE056FD)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    )
                  : null,
              color: hasUnseen ? null : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            ),
            // The padding defines the visible "Ring" border thickness
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                // Crucial fix: The inner container should have a background that matches the theme 
                // but let the image stretch to fill it. 
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // The Story Thumbnail (Full Cover)
                  Image.network(
                    profile.profileUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: isDark ? Colors.grey[900] : Colors.grey[200]);
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? Colors.grey[900] : Colors.grey[200],
                      child: const Center(child: Icon(Icons.person, color: Colors.grey)),
                    ),
                  ),
                  // Darken/Grayscale for seen stories
                  if (!hasUnseen)
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5), // Subtle softening
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.15),
                      ),
                    ),
                  // Interaction Overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black26],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Count Badge
                  if (profile.statuses.length > 1)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${profile.statuses.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile.name.split(' ').first,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: hasUnseen
                  ? (isDark ? Colors.white : const Color(0xFF1F2937))
                  : (isDark ? Colors.grey[600] : const Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<StatusProfile> _getGreetingDummyStories() {
    return [
      StatusProfile(
        id: '1',
        name: 'Design',
        profileUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=400&h=600&fit=crop',
        hasUnseen: true,
        statuses: [const StatusItem(url: '', type: StatusType.image), const StatusItem(url: '', type: StatusType.image)],
      ),
      StatusProfile(
        id: '2',
        name: 'Code',
        profileUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&h=600&fit=crop',
        hasUnseen: true,
        statuses: [const StatusItem(url: '', type: StatusType.image)],
      ),
      StatusProfile(
        id: '3',
        name: 'Lifestyle',
        profileUrl: 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=400&h=600&fit=crop',
        hasUnseen: false,
        statuses: [const StatusItem(url: '', type: StatusType.image)],
      ),
      StatusProfile(
        id: '4',
        name: 'Ideas',
        profileUrl: 'https://images.unsplash.com/photo-1456324504439-367cee3b3c32?w=400&h=600&fit=crop',
        hasUnseen: false,
        statuses: [const StatusItem(url: '', type: StatusType.image)],
      ),
      StatusProfile(
        id: '5',
        name: 'EduProva',
        profileUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400&h=600&fit=crop',
        hasUnseen: true,
        statuses: [const StatusItem(url: '', type: StatusType.image), const StatusItem(url: '', type: StatusType.image), const StatusItem(url: '', type: StatusType.image)],
      ),
    ];
  }
}

class _AddStoryCard extends StatefulWidget {
  const _AddStoryCard();

  @override
  State<_AddStoryCard> createState() => _AddStoryCardState();
}

class _AddStoryCardState extends State<_AddStoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovering = false;
  int _lastClickTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastClickTime < 2500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hold up! Please wait a moment.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    _lastClickTime = now;
    GoRouter.of(context).push(AppRoutes.createStory);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      key: const ValueKey('add_story_mouse_region'),
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovering = true),
        onTapUp: (_) => setState(() => _isHovering = false),
        onTapCancel: () => setState(() => _isHovering = false),
        onTap: _handleTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: _isHovering ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: SizedBox(
                width: 80,
                height: 105,
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F7FF),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _MarchingDashedPainter(
                              color: const Color(0xFF0066FF).withValues(alpha: _isHovering ? 0.6 : 0.4),
                              radius: 23,
                              animationValue: _controller.value,
                            ),
                          );
                        },
                      ),
                    ),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isHovering ? 1.0 : 0.0,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF3B82F6),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isHovering ? 0.25 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutBack,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _isHovering ? const Color(0xFF0066FF) : const Color(0xFF94A3B8),
              ),
              child: const Text('Add Story'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarchingDashedPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double animationValue;

  _MarchingDashedPainter({
    required this.color,
    required this.radius,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        Radius.circular(radius),
      ));

    const double dashWidth = 6;
    const double dashSpace = 4;
    final double totalDashLength = dashWidth + dashSpace;
    
    for (var pathMetric in path.computeMetrics()) {
      double distance = (animationValue * totalDashLength * 12) % totalDashLength - totalDashLength;
      while (distance < pathMetric.length) {
        if (distance + dashWidth > 0) {
          canvas.drawPath(
            pathMetric.extractPath(
              math.max(0, distance),
              math.min(pathMetric.length, distance + dashWidth),
            ),
            paint,
          );
        }
        distance += totalDashLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MarchingDashedPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}
