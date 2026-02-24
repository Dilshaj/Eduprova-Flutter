import 'package:edupurva/core/widgets/shimmer_loading.dart';
import 'package:edupurva/features/courses/screens/course_card.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edupurva/core/utils/image_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupurva/core/widgets/app_loaders.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/course_provider.dart';
import '../models/course_model.dart';
import 'package:hugeicons/hugeicons.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  final List<String> categories = [
    'New Trending',
    'All Courses',
    'Development',
    'Design',
    'Business',
    'Finance & Accounting',
    'IT & Software',
  ];
  String selectedCategory = 'New Trending';

  int _currentBannerIndex = 0;
  final List<String> dummyBanners = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80',
    'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&q=80',
    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coursesProvider.notifier).fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coursesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        title: Text(
          'Courses',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedShoppingCart01,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMoreVerticalCircle01,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Category Tabs
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;
                  return _buildCategoryChip(cat, isSelected, isDark);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Banner Carousel
            Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 185,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentBannerIndex = index;
                      });
                    },
                  ),
                  items: dummyBanners.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade300,
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                imageUrl,
                                cacheManager:
                                    CacheManagers.carouselCacheManager,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.transparent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Black Friday Sale\nends today',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Get ready for your success...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    minimumSize: const Size(100, 36),
                                  ),
                                  child: const Text(
                                    'Save now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dummyBanners.asMap().entries.map((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(
                              alpha: _currentBannerIndex == entry.key
                                  ? 0.9
                                  : 0.4,
                            ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (state.isLoading)
              const ShimmerCoursesScreen()
            else if (state.error != null)
              Center(
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else ...[
              _buildSection(
                title: 'Featured Courses',
                actionLabel: 'Most Popular',
                movies: state.courses.take(6).toList(),
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Recommended',
                movies: state.courses.skip(2).take(6).toList(),
                isDark: isDark,
              ),
              const SizedBox(height: 80), // Padding for the huge navigation bar
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title, bool isSelected, bool isDark) {
    if (title == 'New Trending' && isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF61D8)),
        ),
        child: Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedSparkles,
              color: Color(0xFFFF61D8),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFF61D8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() => selectedCategory = title);
        ref.read(coursesProvider.notifier).fetchCourses(category: title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade400,
          ),
          color: isSelected
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? actionLabel,
    required List<CourseModel> movies,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (actionLabel != null)
              Row(
                children: [
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Color(0xFF4A8BFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF4A8BFF),
                    size: 20,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return CourseCard(course: movies[index], isDark: isDark);
            },
          ),
        ),
      ],
    );
  }
}
