import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/image_cache_manager.dart';
import '../../../../core/widgets/app_loaders.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../models/course_detail_model.dart';
import '../../providers/course_detail_provider.dart';
import '../../../../theme.dart';

import 'tabs/ask_doubts_screen.dart';
import 'tabs/practice_screen.dart';
import 'tabs/notes_screen.dart';
import 'tabs/resources_screen.dart';
import 'tabs/messages_screen.dart';

class CourseLearningScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseLearningScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseLearningScreen> createState() =>
      _CourseLearningScreenState();
}

class _CourseLearningScreenState extends ConsumerState<CourseLearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  int _activeTabIndex = 0;
  bool _isLoading = true;
  bool _isMini = false;
  bool _isFullScreen = false;
  late double _videoHeight;

  int _currentSectionIndex = 0;
  int _currentLessonIndex = 0;
  List<String> _completedLessonIds = [];
  final List<int> _collapsedSections = [];
  Map<int, String> _moduleExamStatus = {0: 'open', 1: 'locked', 2: 'locked'};
  List<int> _unlockedModules = [0];

  final List<String> _tabs = [
    'LESSONS',
    'ASK DOUBTS',
    'PRACTICE',
    'NOTES',
    'RESOURCES',
    'MESSAGES',
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: _tabs.length, vsync: this);
    _mainTabController.addListener(() {
      if (_mainTabController.indexIsChanging ||
          _mainTabController.index != _activeTabIndex) {
        setState(() {
          _activeTabIndex = _mainTabController.index;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    // Check args safely if there is any initial routing data in the future
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  String _formatDuration(num minutes) {
    if (minutes < 60) return '${minutes.toInt()}m';
    int hours = minutes ~/ 60;
    int remainingMins = (minutes % 60).toInt();
    return remainingMins > 0 ? '${hours}h ${remainingMins}m' : '${hours}h';
  }

  void _handleVideoBackPress() {
    if (_activeTabIndex != 0) {
      _mainTabController.animateTo(0);
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.pushReplacement(
          AppRoutes.myLearning,
          extra: {'tab': 'Ongoing'},
        );
      }
    }
  }

  void _toggleSection(int index) {
    if (!_unlockedModules.contains(index)) return;

    setState(() {
      if (_collapsedSections.contains(index)) {
        _collapsedSections.remove(index);
      } else {
        _collapsedSections.add(index);
      }
    });
  }

  bool _checkModuleCompletion(int sectionIndex, List<ChapterModel> curriculum) {
    if (sectionIndex >= curriculum.length) return false;
    final section = curriculum[sectionIndex];
    return section.lectures.every((l) => _completedLessonIds.contains(l.id));
  }

  void _handleModuleExamClick(int sectionIndex, List<ChapterModel> curriculum) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Module Exam'),
        content: const Text(
          'Starting Module Exam... (Demo: Implementing success)',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (sectionIndex + 1 < curriculum.length) {
                  if (!_unlockedModules.contains(sectionIndex + 1)) {
                    _unlockedModules.add(sectionIndex + 1);
                  }
                  _moduleExamStatus[sectionIndex] = 'completed';
                  _moduleExamStatus[sectionIndex + 1] = 'open';
                  _collapsedSections.remove(sectionIndex + 1);
                } else {
                  _moduleExamStatus[sectionIndex] = 'completed';
                }
              });
            },
            child: const Text('Submit Exam'),
          ),
        ],
      ),
    );
  }

  void _handleMarkAsComplete(
    LectureModel currentLesson,
    bool isFinalAssignment,
  ) {
    if (isFinalAssignment) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Starting assessment')));
      return;
    }

    if (!_completedLessonIds.contains(currentLesson.id)) {
      setState(() {
        _completedLessonIds.add(currentLesson.id);
      });
    }
  }

  void _handleNext(bool isFinalAssignment, List<ChapterModel> curriculum) {
    if (isFinalAssignment) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Starting assessment')));
      return;
    }

    if (curriculum.isEmpty) return;

    final currentSection = curriculum[_currentSectionIndex];
    final isLastLessonInSection =
        _currentLessonIndex == currentSection.lectures.length - 1;
    final isLastSection = _currentSectionIndex == curriculum.length - 1;

    if (isLastLessonInSection) {
      if (!isLastSection) {
        if (_unlockedModules.contains(_currentSectionIndex + 1)) {
          setState(() {
            _currentSectionIndex++;
            _currentLessonIndex = 0;
            _collapsedSections.remove(_currentSectionIndex);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please complete the Module Exam to unlock the next module.',
              ),
            ),
          );
        }
      }
    } else {
      setState(() {
        _currentLessonIndex++;
      });
    }
  }

  void _handlePrev(List<ChapterModel> curriculum) {
    if (_currentLessonIndex > 0) {
      setState(() {
        _currentLessonIndex--;
      });
    } else if (_currentSectionIndex > 0) {
      final prevSectionIndex = _currentSectionIndex - 1;
      final prevSectionLessons = curriculum[prevSectionIndex].lectures;
      setState(() {
        _currentSectionIndex = prevSectionIndex;
        _currentLessonIndex = prevSectionLessons.length - 1;
        _collapsedSections.remove(prevSectionIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _videoHeight = screenWidth * (9 / 16);
    final colorScheme = Theme.of(context).colorScheme;
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    final courseAsync = ref.watch(courseLearnProvider(widget.courseId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleVideoBackPress();
      },
      child: Scaffold(
        backgroundColor: themeExt.scaffoldBackgroundColor,
        body: SafeArea(
          child: courseAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (course) {
              final curriculum = course.curriculum;
              if (curriculum.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No curriculum found'),
                      TextButton(
                        onPressed: _handleVideoBackPress,
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              // Ensure bounds
              if (_currentSectionIndex >= curriculum.length) {
                _currentSectionIndex = 0;
              }
              if (_currentLessonIndex >=
                  curriculum[_currentSectionIndex].lectures.length) {
                _currentLessonIndex = 0;
              }

              final currentSection = curriculum[_currentSectionIndex];
              final currentLesson =
                  currentSection.lectures[_currentLessonIndex];

              return Column(
                children: [
                  Expanded(
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          // Video AppBar
                          SliverAppBar(
                            pinned: true,
                            floating: true,
                            elevation: 0,
                            toolbarHeight: math.max(0, kToolbarHeight - 6),
                            scrolledUnderElevation: 0,
                            automaticallyImplyLeading: false,
                            leading: IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.arrow_back_ios_new, size: 18),
                              ),
                              onPressed: _handleVideoBackPress,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: _videoHeight,
                              child: _buildVideoPlayer(course, currentLesson),
                            ),
                          ),

                          // Title Area
                          SliverToBoxAdapter(
                            child: _buildTitleArea(
                              currentSection,
                              currentLesson,
                            ),
                          ),

                          // Sticky TabBar
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverAppBarDelegate(
                              minHeight: 48,
                              maxHeight: 48,
                              child: Container(
                                color: themeExt.scaffoldBackgroundColor,
                                child: TabBar(
                                  controller: _mainTabController,
                                  isScrollable: true,
                                  tabAlignment: .start,
                                  dividerHeight: 1,
                                  dividerColor: themeExt.borderColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  indicatorColor: colorScheme.primary,
                                  indicatorWeight: 3,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  labelColor: colorScheme.primary,
                                  unselectedLabelColor: themeExt.secondaryText,
                                  tabs: _tabs
                                      .map((tab) => Tab(text: tab))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ];
                      },
                      body: TabBarView(
                        controller: _mainTabController,
                        children: [
                          _buildLessonsList(curriculum),
                          const AskDoubtsScreen(),
                          const PracticeScreen(),
                          const NotesScreen(),
                          const ResourcesScreen(),
                          const MessagesScreen(),
                        ],
                      ),
                    ),
                  ),
                  // Footer Navigation (Always Visible at bottom)
                  if (_activeTabIndex == 0 && !_isLoading)
                    _buildFooter(curriculum, currentLesson),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitleArea(
    ChapterModel currentSection,
    LectureModel currentLesson,
  ) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(color: themeExt.scaffoldBackgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentLesson.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${currentSection.title.split(':')[0]} • SECTION ${_currentLessonIndex + 1}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(
    CourseDetailModel course,
    LectureModel currentLecture,
  ) {
    if (currentLecture.muxPlaybackId != null ||
        currentLecture.video != null ||
        currentLecture.videoSource?.playbackId != null) {
      return AppVideoPlayer(
        key: ValueKey(currentLecture.id),
        muxPlaybackId:
            currentLecture.muxPlaybackId ??
            currentLecture.videoSource?.playbackId,
        url: currentLecture.video,
        autoPlay: true,
      );
    }

    if (course.muxPlaybackId != null ||
        course.video != null ||
        course.videoSource?.playbackId != null) {
      return AppVideoPlayer(
        key: ValueKey('promo_${course.id}'),
        muxPlaybackId: course.muxPlaybackId ?? course.videoSource?.playbackId,
        url: course.video,
        autoPlay: true,
      );
    }

    return _buildImage(
      course.thumbnail,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildImage(
    String? url, {
    double? width,
    double? height,
    Widget? placeholder,
  }) {
    if (url == null || url.isEmpty) {
      return placeholder ?? const Icon(Icons.image, color: Colors.grey);
    }

    if (url.startsWith('data:')) {
      try {
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              placeholder ?? const Icon(Icons.broken_image, color: Colors.grey),
        );
      } catch (e) {
        return placeholder ??
            const Icon(Icons.broken_image, color: Colors.grey);
      }
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheManager: CacheManagers.avatarCacheManager,
      placeholder: (context, url) => placeholder ?? const ShimmerImageLoader(),
      errorWidget: (context, url, error) =>
          placeholder ?? const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildLessonsList(List<ChapterModel> curriculum) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: themeExt.scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: curriculum.length,
        itemBuilder: (context, secIdx) {
          final section = curriculum[secIdx];
          final isCollapsed = _collapsedSections.contains(secIdx);
          final isLocked = !_unlockedModules.contains(secIdx);
          final isModuleComplete = _checkModuleCompletion(secIdx, curriculum);
          final examStatus = _moduleExamStatus[secIdx];

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Opacity(
              opacity: isLocked ? 0.6 : 1.0,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _toggleSection(secIdx),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${section.title} ${isLocked ? '🔒' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: themeExt.secondaryText,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          if (!isLocked)
                            Icon(
                              isCollapsed
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              size: 16,
                              color: themeExt.secondaryText,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!isCollapsed && !isLocked)
                    Container(
                      decoration: BoxDecoration(
                        color: themeExt.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: themeExt.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: themeExt.shadowColor,
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            ...((section.lectures).asMap().entries.map((entry) {
                              final lessonIdx = entry.key;
                              final lesson = entry.value;
                              final isCompleted = _completedLessonIds.contains(
                                lesson.id,
                              );
                              final isActive =
                                  secIdx == _currentSectionIndex &&
                                  lessonIdx == _currentLessonIndex;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _currentSectionIndex = secIdx;
                                    _currentLessonIndex = lessonIdx;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? colorScheme.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: themeExt.borderColor.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        margin: const EdgeInsets.only(
                                          right: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? themeExt.successBackgroundColor
                                              : (isActive
                                                    ? colorScheme.primary
                                                    : themeExt.skeletonBase
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )),
                                          shape: BoxShape.circle,
                                          border: isActive
                                              ? null
                                              : Border.all(
                                                  color: themeExt.borderColor,
                                                  width: 1,
                                                ),
                                        ),
                                        alignment: Alignment.center,
                                        child: isCompleted
                                            ? Icon(
                                                Icons.check,
                                                size: 16,
                                                color: themeExt.successColor,
                                              )
                                            : Icon(
                                                isActive
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                size: 16,
                                                color: isActive
                                                    ? Colors.white
                                                    : themeExt.secondaryText,
                                              ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lesson.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isActive
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _formatDuration(lesson.duration),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: themeExt.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()),

                            // Module Exam Row
                            if (secIdx != curriculum.length - 1)
                              InkWell(
                                onTap: isModuleComplete
                                    ? () => _handleModuleExamClick(
                                        secIdx,
                                        curriculum,
                                      )
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isModuleComplete
                                        ? colorScheme.secondary.withValues(
                                            alpha: 0.1,
                                          )
                                        : themeExt.skeletonBase,
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        margin: const EdgeInsets.only(
                                          right: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isModuleComplete
                                              ? colorScheme.secondary
                                                    .withValues(alpha: 0.2)
                                              : themeExt.borderColor,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.assignment_outlined,
                                          size: 16,
                                          color: isModuleComplete
                                              ? colorScheme.secondary
                                              : themeExt.secondaryText,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Module Exam',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isModuleComplete
                                                    ? colorScheme.secondary
                                                    : themeExt.secondaryText,
                                              ),
                                            ),
                                            Text(
                                              isModuleComplete
                                                  ? (examStatus == 'completed'
                                                        ? 'Completed ✅'
                                                        : 'Ready to start')
                                                  : 'Complete all lessons to unlock',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: themeExt.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isModuleComplete)
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 16,
                                          color: colorScheme.secondary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(
    List<ChapterModel> curriculum,
    LectureModel currentLesson,
  ) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final isFinalCaseStudy = currentLesson.title.toLowerCase().contains(
      'final case study',
    );
    final isFinalAssignment = currentLesson.title.toLowerCase().contains(
      'final assignment',
    );
    final isLessonCompleted = _completedLessonIds.contains(currentLesson.id);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        border: Border(top: BorderSide(color: themeExt.borderColor)),
        boxShadow: [
          BoxShadow(
            color: themeExt.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prev
          InkWell(
            onTap: () => _handlePrev(curriculum),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Main Action
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: (!isFinalAssignment && isLessonCompleted)
                    ? null
                    : () => _handleMarkAsComplete(
                        currentLesson,
                        isFinalAssignment,
                      ),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: isFinalAssignment
                          ? [colorScheme.secondary, themeExt.saleColor]
                          : (isLessonCompleted
                                ? [
                                    themeExt.successColor,
                                    themeExt.successColor.withValues(
                                      alpha: 0.8,
                                    ),
                                  ]
                                : [
                                    themeExt.gradiantStart,
                                    themeExt.gradiantEnd,
                                  ]),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isFinalAssignment
                        ? 'START ASSESSMENT'
                        : isFinalCaseStudy
                        ? (isLessonCompleted ? 'COMPLETED' : 'MARK AS READ')
                        : (isLessonCompleted
                              ? 'COMPLETED'
                              : 'MARK AS COMPLETE'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Next
          InkWell(
            onTap: () => _handleNext(isFinalAssignment, curriculum),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
