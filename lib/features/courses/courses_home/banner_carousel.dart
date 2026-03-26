import 'package:flutter/material.dart';
import 'dart:async';

final List<Map<String, String>> carouselData = [
  {
    'id': '1',
    'title': 'Black Friday Sale ends today',
    'subtitle':
        'Get ready for your success era with courses as low as ₹399. Hurry before it ends.',
    'buttonText': 'Save now',
    'image':
        'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
  },
  {
    'id': '2',
    'title': 'Unlock Your Potential',
    'subtitle':
        'Learn new skills from top instructors around the world. Start today!',
    'buttonText': 'Explore',
    'image':
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
  },
  {
    'id': '3',
    'title': 'Learn Anytime, Anywhere',
    'subtitle':
        'Mobile learning at your fingertips. Download courses and learn offline.',
    'buttonText': 'Get Started',
    'image':
        'https://images.unsplash.com/photo-1522071820081-009f0129c71c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
  },
];

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _activeIndex = 0;
  Timer? _autoScrollTimer;
  bool _isManualScroll = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isManualScroll && _pageController.hasClients) {
        int nextIndex = _activeIndex + 1;
        if (nextIndex >= carouselData.length) {
          nextIndex = 0;
          _pageController.jumpToPage(
            nextIndex,
          ); // Seamless loop would be better, but jumping works for now
        } else {
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _onManualScrollStart() {
    _isManualScroll = true;
    _autoScrollTimer?.cancel();
  }

  void _onManualScrollEnd() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _isManualScroll = false;
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollStartNotification) {
                _onManualScrollStart();
              } else if (notification is ScrollEndNotification) {
                _onManualScrollEnd();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _activeIndex = index);
              },
              itemCount: carouselData.length,
              itemBuilder: (context, index) {
                final item = carouselData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF3B82F6)),
                        ),
                        Container(color: Colors.black.withValues(alpha: 0.4)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['subtitle']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFEEEEEE),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  item['buttonText']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: carouselData.asMap().entries.map((entry) {
            final index = entry.key;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: PaginationDot(isActive: index == _activeIndex),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class PaginationDot extends StatefulWidget {
  final bool isActive;

  const PaginationDot({super.key, required this.isActive});

  @override
  State<PaginationDot> createState() => _PaginationDotState();
}

class _PaginationDotState extends State<PaginationDot>
    with TickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Same as AUTO_SCROLL_INTERVAL
    );

    if (widget.isActive) {
      _progressController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant PaginationDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _progressController.forward(from: 0.0);
      } else {
        _progressController.stop();
        _progressController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 4,
      width: widget.isActive ? 24 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5DB).withValues(alpha: 0.5), // Light grey for inactive
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (widget.isActive)
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _progressController.value,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF), // Primary blue for active fill
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
