import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'stories_provider.dart';
import 'storie_view_screen.dart';

class StatusUsersPager extends ConsumerStatefulWidget {
  final int initialIndex;

  const StatusUsersPager({super.key, required this.initialIndex});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StatusUsersPagerState();
}

class _StatusUsersPagerState extends ConsumerState<StatusUsersPager> {
  late PageController _pageController;
  double _currentPageValue = 0.0;
  double _bgOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPageValue = widget.initialIndex.toDouble();
    _pageController.addListener(() {
      if (mounted) {
        final double? page = _pageController.page;
        if (page != null) {
          setState(() {
            _currentPageValue = page;
          });
          
          // Precache next profile's first image for speed
          final nextIndex = page.floor() + 1;
          final profilesAsync = ref.read(statusProfilesProvider);
          profilesAsync.whenData((profiles) {
            final displayProfiles = profiles.isEmpty ? getGreetingDummyStories() : profiles;
            if (nextIndex < displayProfiles.length) {
              final firstStatus = displayProfiles[nextIndex].statuses.firstOrNull;
              if (firstStatus?.type == StatusType.image) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    precacheImage(
                      CachedNetworkImageProvider(firstStatus!.url),
                      context,
                    );
                  }
                });
              }
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onComplete(int currentIndex, int totalUsers) {
    if (currentIndex < totalUsers - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600), // Slower, more deliberate transition
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onPrevious(int currentIndex) {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600), // Slower, more deliberate transition
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(statusProfilesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Solid black background (hides home screen perfectly during viewing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(_bgOpacity),
            ),
          ),
          profilesAsync.when(
            data: (profiles) {
              final displayProfiles = profiles.isEmpty ? getGreetingDummyStories() : profiles;
              return PageView.builder(
            controller: _pageController,
            itemCount: displayProfiles.length,
            itemBuilder: (context, index) {
              final double value = _currentPageValue - index;

              if (value <= -1.0 || value >= 1.0) {
                return const SizedBox.shrink();
              }

              // Modern Fixed-Depth Slide (Curtain) Transition Logic
              double xTranslation = 0.0;
              double opacity = 1.0;
              double overlayOpacity = 0.0;

              if (value < 0) {
                // Outgoing page (being covered)
                // We counter-translate it to stay fixed while the next page slides on top
                xTranslation = -value * MediaQuery.sizeOf(context).width; 
                opacity = 1.0;
                // Add a subtle darkening as it's covered
                overlayOpacity = value.abs() * 0.5;
              } else {
                // Incoming page (sliding over)
                xTranslation = 0.0; // Standard slide-in
                opacity = 1.0;
                overlayOpacity = 0.0;
              }

              return Transform.translate(
                offset: Offset(xTranslation, 0.0),
                child: Stack(
                  children: [
                    StatusViewScreen(
                      profile: displayProfiles[index],
                      pageOffset: value,
                      onComplete: () => _onComplete(index, displayProfiles.length),
                      onPrevious: () => _onPrevious(index),
                      onDrag: (opacity) => setState(() => _bgOpacity = opacity),
                    ),
                    if (value < 0)
                      IgnorePointer(
                        child: Container(
                          color: Colors.black.withValues(alpha: overlayOpacity),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => const Center(child: Icon(Icons.error_outline)),
      ),
    ],
  ),
);
}
}
