import 'package:eduprova/features/courses/providers/enrolled_courses_provider.dart';
import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_routes.dart';

// CourseData and coursesData removed as they are replaced by live models

// Status color helpers removed from global scope to be handled within state with theme context

class MyLearningScreen extends ConsumerStatefulWidget {
  const MyLearningScreen({super.key});

  @override
  ConsumerState<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends ConsumerState<MyLearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Ongoing', 'Completed'];
  String _searchQuery = '';
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['tab'] != null) {
        String targetTab = args['tab'];
        int index = _tabs.indexOf(targetTab);
        if (index != -1) {
          _tabController.index = index;
        }
      }
    });
  }

  Color _getStatusColor(
    String status,
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case 'Fresh':
        return themeExt.purpleAccentColor;
      case 'Ongoing':
        return colorScheme.primary.withValues(alpha: 0.1);
      case 'Completed':
        return themeExt.successBackgroundColor;
      default:
        return themeExt.borderColor;
    }
  }

  Color _getStatusTextColor(
    String status,
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case 'Fresh':
        return themeExt.purpleAccentTextColor;
      case 'Ongoing':
        return colorScheme.primary;
      case 'Completed':
        return themeExt.successColor;
      default:
        return themeExt.secondaryText;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: themeExt.scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(color: themeExt.borderColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      context.pop();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _isSearchOpen
                        ? Container(
                            height: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: themeExt.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 18,
                                  color: themeExt.secondaryText,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    autofocus: true,
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search...',
                                      hintStyle: TextStyle(
                                        color: themeExt.secondaryText,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            'My Courses',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSearchOpen = !_isSearchOpen;
                        if (!_isSearchOpen) _searchQuery = '';
                      });
                    },
                    child: Icon(
                      _isSearchOpen ? Icons.close : Icons.search,
                      size: 26,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: themeExt.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: themeExt.borderColor),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(6),
                  labelColor: colorScheme.onSurface,
                  unselectedLabelColor: themeExt.secondaryText,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) => _buildCoursePage(tab)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursePage(String tab) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final enrolledState = ref.watch(enrolledCoursesProvider);

    if (enrolledState.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (context, index) => const _CourseSkeleton(),
      );
    }

    if (enrolledState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              enrolledState.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(enrolledCoursesProvider.notifier)
                  .fetchEnrolledCourses(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final courses = enrolledState.courses;

    final filteredCourses = courses.where((course) {
      bool matchesTab = false;
      if (tab == 'All') {
        matchesTab = true;
      } else if (tab == 'Ongoing') {
        matchesTab = course.progress > 0 && course.progress < 100;
      } else if (tab == 'Completed') {
        matchesTab = course.progress == 100;
      }
      final matchesSearch =
          _searchQuery.isEmpty ||
          course.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();

    if (filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 48, color: themeExt.secondaryText),
            const SizedBox(height: 16),
            Text(
              'No courses found',
              style: TextStyle(
                color: themeExt.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(enrolledCoursesProvider.notifier).fetchEnrolledCourses(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ).copyWith(bottom: 40),
        itemCount: filteredCourses.length,
        itemBuilder: (context, index) {
          final item = filteredCourses[index];
          final derivedStatus = item.status;

          final colorScheme = theme.colorScheme;

          Color progressBarColor = colorScheme.primary;
          String buttonText = '';
          Color buttonTextColor = colorScheme.primary;
          Color iconColor = colorScheme.primary;
          String statusText = '';
          Color dotColor = colorScheme.primary;

          switch (derivedStatus) {
            case 'Fresh':
              progressBarColor = themeExt.purpleAccentTextColor;
              buttonText = 'Start Course';
              buttonTextColor = themeExt.purpleAccentTextColor;
              iconColor = themeExt.purpleAccentTextColor;
              statusText = item.nextLesson != null
                  ? 'Next: ${item.nextLesson}'
                  : 'Ready to Start';
              dotColor = themeExt.purpleAccentTextColor;
              break;
            case 'Ongoing':
              progressBarColor = colorScheme.primary;
              buttonText = 'Continue';
              buttonTextColor = colorScheme.primary;
              iconColor = colorScheme.primary;
              statusText = item.nextLesson != null
                  ? 'Next: ${item.nextLesson}'
                  : 'Continue Learning';
              dotColor = colorScheme.primary;
              break;
            case 'Completed':
              progressBarColor = themeExt.successColor;
              buttonText = 'View Again';
              buttonTextColor = themeExt.successColor;
              iconColor = themeExt.successColor;
              statusText = 'Course Completed';
              dotColor = themeExt.successColor;
              break;
          }

          bool isClickable = true;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeExt.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: themeExt.borderColor),
              boxShadow: [
                BoxShadow(
                  color: themeExt.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        item.image,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 96,
                          height: 96,
                          color: const Color(0xFF3B82F6),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.instructor,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: themeExt.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.progress}% Complete',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    derivedStatus,
                                    themeExt,
                                    colorScheme,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  derivedStatus.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusTextColor(
                                      derivedStatus,
                                      themeExt,
                                      colorScheme,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: themeExt.progressBarBackgroundColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: item.progress / 100.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: progressBarColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: themeExt.borderColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              statusText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: themeExt.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: 1.0,
                      child: InkWell(
                        onTap: () {
                          if (isClickable) {
                            context.push(AppRoutes.courseLearning(item.id));
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              buttonText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: buttonTextColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: iconColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourseSkeleton extends StatefulWidget {
  const _CourseSkeleton();

  @override
  State<_CourseSkeleton> createState() => _CourseSkeletonState();
}

class _CourseSkeletonState extends State<_CourseSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeExt.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: themeExt.borderColor),
              boxShadow: [
                BoxShadow(
                  color: themeExt.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: themeExt.skeletonBase,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: themeExt.skeletonBase,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 12,
                            decoration: BoxDecoration(
                              color: themeExt.skeletonBase,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 60,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: themeExt.skeletonBase,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: themeExt.skeletonBase,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            height: 6,
                            decoration: BoxDecoration(
                              color: themeExt.skeletonBase,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: themeExt.borderColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: themeExt.skeletonBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: themeExt.skeletonBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
