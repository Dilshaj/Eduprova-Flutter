import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'status_provider.dart';
import 'status_view_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPageValue = widget.initialIndex.toDouble();
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page ?? 0.0;
      });
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onPrevious(int currentIndex) {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(statusProfilesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final double value = _currentPageValue - index;

          if (value <= -1.0 || value >= 1.0) {
            return const SizedBox.shrink();
          }

          return Transform(
            alignment: value > 0 ? Alignment.centerRight : Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(-value * (pi / 2)),
            child: StatusViewScreen(
              profile: profiles[index],
              pageOffset: value,
              onComplete: () => _onComplete(index, profiles.length),
              onPrevious: () => _onPrevious(index),
            ),
          );
        },
      ),
    );
  }
}
