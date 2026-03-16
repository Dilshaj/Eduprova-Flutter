import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/ui/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import 'package:go_router/go_router.dart';

import 'banner_carousel.dart';
import 'category_tabs.dart';
import 'courses_header.dart';
import 'horizontal_course_row.dart';
import '../widgets/skeleton_loader.dart';

import '../../../theme/theme.dart';
import '../core/models/course_model.dart';
import '../core/providers/course_provider.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  bool filterModalVisible = false;
  bool isPopularDropdownOpen = false;
  String popularFilterSelection = 'Most Popular';
  String selectedSort = 'Most Relevant';
  List<String> selectedDurations = ['3-6 Hours'];

  bool practiceExpanded = true;
  Map<String, bool> practiceChecks = {
    'quizzes': false,
    'coding': false,
    'practice': false,
    'role': false,
  };

  int currentPage = 1;
  final int rowsPerPage = 5;
  final int itemsPerRow = 6;
  late final int titlesPerPage;

  @override
  void initState() {
    super.initState();
    titlesPerPage = rowsPerPage * itemsPerRow;
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coursesProvider.notifier).fetchCourses();
    });
  }

  void togglePracticeCheck(String key) {
    setState(() {
      practiceChecks[key] = !(practiceChecks[key] ?? false);
    });
  }

  List<CourseModel> getCurrentPageCourses(List<CourseModel> allCourses) {
    int startIndex = (currentPage - 1) * titlesPerPage;
    int endIndex = startIndex + titlesPerPage;
    if (startIndex >= allCourses.length) return [];
    return allCourses.sublist(startIndex, min(endIndex, allCourses.length));
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final coursesState = ref.watch(coursesProvider);
    final allCourses = coursesState.courses;
    final isLoading = coursesState.isLoading;

    int totalPages = (allCourses.length / titlesPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    List<CourseModel> currentCourses = getCurrentPageCourses(allCourses);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: themeExt.scaffoldBackgroundColor,
        body: Stack(
          children: [
            AppBackground(),
            SafeArea(
              child: Column(
                children: [
                  const CoursesHeader(),
                  Expanded(
                    child: isLoading
                        ? const CoursesHomeSkeleton()
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(coursesProvider.notifier)
                                .fetchCourses(),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 80),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Actions Row
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      16,
                                      0,
                                      16,
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // All Courses - Gradient
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            child: InkWell(
                                              onTap: () {},
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      themeExt.buyNowGradient,
                                                  // gradient: LinearGradient(
                                                  //   colors: [
                                                  //     colorScheme.primary,
                                                  //     themeExt
                                                  //         .highestRatedBadgeColor,
                                                  //   ],
                                                  //   begin: Alignment.centerLeft,
                                                  //   end: Alignment.centerRight,
                                                  // ),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: const Text(
                                                  'All Courses',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // My Learning
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                context.push(
                                                  AppRoutes.myLearning,
                                                  extra: {'tab': 'Ongoing'},
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: themeExt.cardColor,
                                                  border: Border.all(
                                                    color: themeExt.borderColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          themeExt.shadowColor,
                                                      blurRadius: 2,
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.school_outlined,
                                                      size: 16,
                                                      color: themeExt
                                                          .secondaryText,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'My Learning',
                                                      style: TextStyle(
                                                        color: colorScheme
                                                            .onSurface,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Wishlist
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 20,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                context.push(
                                                  AppRoutes.myWishlist,
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: themeExt.cardColor,
                                                  border: Border.all(
                                                    color: themeExt.borderColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          themeExt.shadowColor,
                                                      blurRadius: 2,
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.favorite_border,
                                                      size: 16,
                                                      color: themeExt
                                                          .secondaryText,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Wishlist',
                                                      style: TextStyle(
                                                        color: colorScheme
                                                            .onSurface,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const CategoryTabs(),
                                  const BannerCarousel(),
                                  const SizedBox(height: 10),

                                  // Rows
                                  if (currentCourses.isEmpty)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(40.0),
                                        child: Text("No courses found."),
                                      ),
                                    )
                                  else
                                    ...List.generate(rowsPerPage, (rowIndex) {
                                      int start = rowIndex * itemsPerRow;
                                      int end = (rowIndex + 1) * itemsPerRow;
                                      if (start >= currentCourses.length) {
                                        return const SizedBox.shrink();
                                      }
                                      List<CourseModel> rowCourses =
                                          currentCourses.sublist(
                                            start,
                                            min(end, currentCourses.length),
                                          );
                                      if (rowCourses.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return HorizontalCourseRow(
                                        title: rowIndex == 0
                                            ? "Featured Courses"
                                            : "More Courses",
                                        courses: rowCourses,
                                        categoryId: "Category-$rowIndex",
                                      );
                                    }),

                                  // Pagination
                                  if (totalPages > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16,
                                        bottom: 32,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: currentPage > 1
                                                ? () => setState(
                                                    () => currentPage--,
                                                  )
                                                : null,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              margin: const EdgeInsets.only(
                                                right: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: currentPage == 1
                                                      ? themeExt.borderColor
                                                      : colorScheme.primary,
                                                ),
                                                color: currentPage == 1
                                                    ? themeExt.skeletonBase
                                                    : themeExt.cardColor,
                                              ),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.chevron_left,
                                                size: 20,
                                                color: currentPage == 1
                                                    ? themeExt.secondaryText
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Page $currentPage of $totalPages',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: currentPage < totalPages
                                                ? () => setState(
                                                    () => currentPage++,
                                                  )
                                                : null,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              margin: const EdgeInsets.only(
                                                left: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      currentPage == totalPages
                                                      ? themeExt.borderColor
                                                      : colorScheme.primary,
                                                ),
                                                color: currentPage == totalPages
                                                    ? themeExt.skeletonBase
                                                    : themeExt.cardColor,
                                              ),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.chevron_right,
                                                size: 20,
                                                color: currentPage == totalPages
                                                    ? themeExt.secondaryText
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 96),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // FILTER MODAL (truncated for readability)
            if (filterModalVisible)
              GestureDetector(
                onTap: () => setState(() => filterModalVisible = false),
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap from closing
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: themeExt.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: themeExt.shadowColor,
                            spreadRadius: 5,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filter',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => filterModalVisible = false),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.close,
                                    size: 24,
                                    color: themeExt.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Filter content can be restored if needed
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
