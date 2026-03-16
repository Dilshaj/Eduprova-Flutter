import 'dart:convert';
import 'package:eduprova/features/courses/course_learn/tabs/ask_doubts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_player/video_player.dart' as vp;

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/global_mini_player_service.dart';
import '../../../core/utils/image_cache_manager.dart';
import '../../../core/widgets/app_loaders.dart';
import '../../../core/widgets/app_video_player.dart';
import '../core/models/course_detail_model.dart';
import '../core/models/enrolled_course_model.dart';
import '../core/providers/course_detail_provider.dart';
import '../core/providers/progress_provider.dart';
import '../../../theme/theme.dart';

// import 'tabs/ask_doubts_screen.dart';
import 'tabs/practice_screen.dart';
import 'tabs/notes_screen.dart';
import 'tabs/resources_screen.dart';
import 'tabs/messages_screen.dart';

class CourseLearningScreen extends ConsumerStatefulWidget {
  final String courseId;
  final int? resumePositionMs;
  final bool resumeAutoPlay;
  final String? resumeLectureId;
  final bool resumeFromMini;

  const CourseLearningScreen({
    super.key,
    required this.courseId,
    this.resumePositionMs,
    this.resumeAutoPlay = true,
    this.resumeLectureId,
    this.resumeFromMini = false,
  });

  @override
  ConsumerState<CourseLearningScreen> createState() =>
      _CourseLearningScreenState();
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}

class _CourseLearningScreenState extends ConsumerState<CourseLearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  int _activeTabIndex = 0;
  bool _isLoading = true;
  late double _videoHeight;
  final AppVideoPlayerController _videoPlayerController =
      AppVideoPlayerController();
  bool _isMiniPlayer = false;
  double _inlineCollapseProgress = 0;

  int _currentSectionIndex = 0;
  int _currentLessonIndex = 0;
  bool _didApplyResumeLecture = false;
  DateTime? _lastWatchSyncTime;
  Duration? _lastSentPosition;

  bool _didTryAdoptGlobalMini = false;
  Player? _adoptedMediaPlayer;
  vp.VideoPlayerController? _adoptedVideoController;
  final List<int> _collapsedSections = [];

  List<String> _getCompletedLessonIds(ProgressState progress) {
    return progress.data?.completedLectures ?? [];
  }

  List<String> get _completedLessonIds =>
      ref
          .read(courseProgressProvider(widget.courseId))
          .data
          ?.completedLectures ??
      [];

  bool _isLectureUnlocked(
    int secIdx,
    int lessonIdx,
    List<ChapterModel>? curriculum,
    ProgressModel? progress,
  ) {
    if (curriculum == null || curriculum.isEmpty) return true;
    if (secIdx == 0 && lessonIdx == 0) return true;

    final completedIds = progress?.completedLectures ?? [];
    final completedExams = progress?.completedExams ?? [];

    int prevSecIdx = secIdx;
    int prevLessonIdx = lessonIdx - 1;

    if (prevLessonIdx < 0) {
      prevSecIdx = secIdx - 1;
      if (prevSecIdx < 0) return true;

      // If we are at the start of a new module,
      // check if the previous module's exam is completed if it has one.
      final prevSection = curriculum[prevSecIdx];
      if (prevSection.hasExam && !completedExams.contains(prevSection.id)) {
        return false;
      }

      if (prevSection.lectures.isEmpty) return true;
      prevLessonIdx = prevSection.lectures.length - 1;
    }

    final prevLectureId = curriculum[prevSecIdx].lectures[prevLessonIdx].id;
    return completedIds.contains(prevLectureId);
  }

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
    if (_isMiniPlayer) {
      _videoPlayerController.exitMiniPlayer();
      return;
    }
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

  void _toggleSection(int index, List<ChapterModel> curriculum) {
    setState(() {
      if (_collapsedSections.contains(index)) {
        _collapsedSections.remove(index);
      } else {
        _collapsedSections.add(index);
      }
    });
  }

  bool _checkModuleCompletion(
    int sectionIndex,
    List<ChapterModel> curriculum,
    List<String> completedIds,
  ) {
    if (sectionIndex >= curriculum.length || sectionIndex < 0) return false;
    final section = curriculum[sectionIndex];
    if (section.lectures.isEmpty) return true;
    return section.lectures.every((l) => completedIds.contains(l.id));
  }

  void _handlePositionChanged(String lectureId, Duration position) {
    if (!mounted) return;

    final now = DateTime.now();
    // Sync every 10 seconds or if moved significantly (more than 5s skip)
    final shouldSync =
        _lastWatchSyncTime == null ||
        now.difference(_lastWatchSyncTime!) > const Duration(seconds: 10) ||
        (_lastSentPosition != null &&
            (position.inSeconds - _lastSentPosition!.inSeconds).abs() > 5);

    if (shouldSync && position > Duration.zero) {
      _lastWatchSyncTime = now;
      _lastSentPosition = position;

      ref
          .read(allCourseProgressProvider.notifier)
          .updateWatchTime(widget.courseId, lectureId, position.inSeconds);
    }
  }

  void _handleVideoFinished(
    LectureModel lecture,
    List<ChapterModel> curriculum,
  ) {
    if (!_completedLessonIds.contains(lecture.id)) {
      _handleMarkAsComplete(lecture, false);
    }
    _handleNext(false, curriculum);
  }

  Duration? _getInitialPositionForLecture(
    LectureModel lecture,
    ProgressModel? progress,
  ) {
    if (progress == null) return null;
    final watchTimeSeconds = progress.videoWatchTimes[lecture.id];
    if (watchTimeSeconds != null && watchTimeSeconds > 0) {
      return Duration(seconds: watchTimeSeconds.toInt());
    }
    return null;
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
              final section = curriculum[sectionIndex];
              ref
                  .read(allCourseProgressProvider.notifier)
                  .markExamCompleted(widget.courseId, section.id);

              if (sectionIndex + 1 < curriculum.length) {
                _collapsedSections.remove(sectionIndex + 1);
              }
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
      ref
          .read(allCourseProgressProvider.notifier)
          .markLectureCompleted(widget.courseId, currentLesson.id);
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
        setState(() {
          _currentSectionIndex++;
          _currentLessonIndex = 0;
          _collapsedSections.remove(_currentSectionIndex);
        });
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
    final progressAsync = ref.watch(courseProgressProvider(widget.courseId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleVideoBackPress();
      },
      child: Scaffold(
        backgroundColor: themeExt.scaffoldBackgroundColor.withValues(
          alpha: (1 - _inlineCollapseProgress).clamp(0.0, 1.0),
        ),
        body: SafeArea(
          child: ColoredBox(
            color: themeExt.scaffoldBackgroundColor.withValues(
              alpha: (1 - _inlineCollapseProgress).clamp(0.0, 1.0),
            ),
            child: courseAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (course) {
                if (progressAsync.isLoading && progressAsync.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

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

                if (!_didApplyResumeLecture) {
                  String? targetLectureId = widget.resumeLectureId;
                  final progressData = progressAsync.data;

                  if ((targetLectureId == null || targetLectureId.isEmpty) &&
                      progressData?.lastAccessedLectureId != null &&
                      progressData!.lastAccessedLectureId!.isNotEmpty) {
                    targetLectureId = progressData.lastAccessedLectureId;
                  }

                  if (targetLectureId != null && targetLectureId.isNotEmpty) {
                    for (var s = 0; s < curriculum.length; s++) {
                      final lectures = curriculum[s].lectures;
                      for (var l = 0; l < lectures.length; l++) {
                        if (lectures[l].id == targetLectureId) {
                          _currentSectionIndex = s;
                          _currentLessonIndex = l;
                          _didApplyResumeLecture = true;
                          break;
                        }
                      }
                      if (_didApplyResumeLecture) break;
                    }
                  }

                  // Even if we didn't find the target, flag it applied so we don't try again
                  _didApplyResumeLecture = true;
                }

                final currentSection = curriculum[_currentSectionIndex];
                final currentLesson =
                    currentSection.lectures[_currentLessonIndex];

                if (widget.resumeFromMini && !_didTryAdoptGlobalMini) {
                  _didTryAdoptGlobalMini = true;
                  final mini =
                      GlobalMiniPlayerService.instance.takePendingHandoff() ??
                      GlobalMiniPlayerService.instance.session.value;
                  final targetUrl = _resolveMediaUrlForLecture(
                    course,
                    currentLesson,
                  );
                  if (mini != null &&
                      targetUrl != null &&
                      mini.mediaUrl == targetUrl &&
                      ((mini.engine == AppVideoEngine.mediaKit &&
                              mini.mediaPlayer != null) ||
                          (mini.engine == AppVideoEngine.videoPlayer &&
                              mini.videoPlayerController != null))) {
                    _adoptedMediaPlayer = mini.mediaPlayer;
                    _adoptedVideoController = mini.videoPlayerController;
                    GlobalMiniPlayerService.instance.close();
                  } else {
                    GlobalMiniPlayerService.instance.restorePendingIfAny();
                  }
                }

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOut,
                            offset: Offset(0, _inlineCollapseProgress * 0.14),
                            child: Transform.scale(
                              scale: 1 - (_inlineCollapseProgress * 0.12),
                              alignment: Alignment.topCenter,
                              child: Opacity(
                                opacity: 1 - _inlineCollapseProgress,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: _videoHeight,
                                        ),
                                        child: NestedScrollView(
                                          headerSliverBuilder: (context, innerBoxIsScrolled) {
                                            return [
                                              SliverToBoxAdapter(
                                                child: _buildTitleArea(
                                                  currentSection,
                                                  currentLesson,
                                                ),
                                              ),
                                              SliverOverlapAbsorber(
                                                handle:
                                                    NestedScrollView.sliverOverlapAbsorberHandleFor(
                                                      context,
                                                    ),

                                                // sliver:  MultiSliver( children: []),
                                                sliver: SliverPersistentHeader(
                                                  pinned: true,
                                                  delegate: _PinnedHeaderDelegate(
                                                    height: 48,
                                                    child: Container(
                                                      color: themeExt
                                                          .scaffoldBackgroundColor,
                                                      child: TabBar(
                                                        controller:
                                                            _mainTabController,
                                                        isScrollable: true,
                                                        tabAlignment: .start,
                                                        dividerHeight: 1,
                                                        dividerColor: themeExt
                                                            .borderColor,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                            ),
                                                        indicatorColor:
                                                            colorScheme.primary,
                                                        indicatorWeight: 3,
                                                        indicatorSize:
                                                            TabBarIndicatorSize
                                                                .label,
                                                        labelColor:
                                                            colorScheme.primary,
                                                        unselectedLabelColor:
                                                            themeExt
                                                                .secondaryText,
                                                        tabs: _tabs
                                                            .map(
                                                              (tab) => Tab(
                                                                text: tab,
                                                              ),
                                                            )
                                                            .toList(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ];
                                          },
                                          body: TabBarView(
                                            controller: _mainTabController,
                                            children: [
                                              _buildLessonsList(
                                                curriculum,
                                                progressAsync,
                                              ),
                                              AskDoubtsScreen(
                                                courseId: widget.courseId,
                                                lectureId: currentLesson.id,
                                              ),
                                              const PracticeScreen(),
                                              const NotesScreen(),
                                              ResourcesScreen(
                                                resources: curriculum
                                                    .expand((s) => s.lectures)
                                                    .expand(
                                                      (l) => l.attachments,
                                                    )
                                                    .toList(),
                                              ),
                                              MessagesScreen(
                                                courseId: widget.courseId,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_activeTabIndex == 0 && !_isLoading)
                                      _buildFooter(
                                        curriculum,
                                        currentLesson,
                                        _getCompletedLessonIds(progressAsync),
                                        progressAsync.data,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: _videoHeight,
                      child: _buildVideoPlayer(
                        course,
                        currentLesson,
                        controller: _videoPlayerController,
                        adoptedMediaPlayer: _adoptedMediaPlayer,
                        adoptedVideoPlayerController: _adoptedVideoController,
                        onMiniPlayerChanged: (isMini) {
                          if (!mounted) return;
                          setState(() {
                            _isMiniPlayer = isMini;
                            _inlineCollapseProgress = isMini ? 1 : 0;
                          });
                        },
                        onInlineCollapseProgressChanged: (progress) {
                          if (!mounted) return;
                          setState(() {
                            _inlineCollapseProgress = progress;
                          });
                        },
                        onInlineMiniPlayerRequest: (snapshot) {
                          GlobalMiniPlayerService.instance.start(snapshot);
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.pushReplacement(
                              AppRoutes.myLearning,
                              extra: {'tab': 'Ongoing'},
                            );
                          }
                          return true;
                        },
                        inlineMiniBottomInset:
                            (_activeTabIndex == 0 && !_isLoading) ? 90 : 0,
                      ),
                    ),
                  ],
                );
              },
            ),
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
    LectureModel currentLecture, {
    AppVideoPlayerController? controller,
    Player? adoptedMediaPlayer,
    vp.VideoPlayerController? adoptedVideoPlayerController,
    ValueChanged<bool>? onMiniPlayerChanged,
    ValueChanged<double>? onInlineCollapseProgressChanged,
    bool Function(AppVideoMiniSnapshot snapshot)? onInlineMiniPlayerRequest,
    double inlineMiniBottomInset = 0,
  }) {
    if (currentLecture.muxPlaybackId != null ||
        currentLecture.video != null ||
        currentLecture.videoSource?.playbackId != null) {
      return AppVideoPlayer(
        key: ValueKey(currentLecture.id),
        muxPlaybackId:
            currentLecture.muxPlaybackId ??
            currentLecture.videoSource?.playbackId,
        url: currentLecture.video,
        autoPlay: widget.resumeAutoPlay,
        initialPosition: widget.resumePositionMs != null
            ? Duration(milliseconds: widget.resumePositionMs!)
            : _getInitialPositionForLecture(
                currentLecture,
                ref.read(courseProgressProvider(widget.courseId)).data,
              ),
        adoptedMediaPlayer: adoptedMediaPlayer,
        adoptedVideoPlayerController: adoptedVideoPlayerController,
        controller: controller,
        onPositionChanged: (pos) =>
            _handlePositionChanged(currentLecture.id, pos),
        onFinished: () =>
            _handleVideoFinished(currentLecture, course.curriculum),
        onMiniPlayerChanged: onMiniPlayerChanged,
        onInlineCollapseProgress: onInlineCollapseProgressChanged,
        onInlineMiniPlayerRequest: onInlineMiniPlayerRequest,
        inlineMiniBottomInset: inlineMiniBottomInset,
        engine: .videoPlayer,
        restoreRouteOnExpand:
            '/course/${widget.courseId}/learn?lectureId=${Uri.encodeComponent(currentLecture.id)}',
      );
    }

    if (course.muxPlaybackId != null ||
        course.video != null ||
        course.videoSource?.playbackId != null) {
      return AppVideoPlayer(
        key: ValueKey('promo_${course.id}'),
        muxPlaybackId: course.muxPlaybackId ?? course.videoSource?.playbackId,
        url: course.video,
        autoPlay: widget.resumeAutoPlay,
        initialPosition: widget.resumePositionMs != null
            ? Duration(milliseconds: widget.resumePositionMs!)
            : null,
        adoptedMediaPlayer: adoptedMediaPlayer,
        adoptedVideoPlayerController: adoptedVideoPlayerController,
        controller: controller,
        onMiniPlayerChanged: onMiniPlayerChanged,
        onInlineCollapseProgress: onInlineCollapseProgressChanged,
        onInlineMiniPlayerRequest: onInlineMiniPlayerRequest,
        inlineMiniBottomInset: inlineMiniBottomInset,
        restoreRouteOnExpand:
            '/course/${widget.courseId}/learn?lectureId=${Uri.encodeComponent(currentLecture.id)}',
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

  Widget _buildLessonsList(
    List<ChapterModel> curriculum,
    ProgressState progress,
  ) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final completedIds = _getCompletedLessonIds(progress);

    return Container(
      color: themeExt.scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16 + 48, 20, 100),
        itemCount: curriculum.length,
        itemBuilder: (context, secIdx) {
          final section = curriculum[secIdx];
          final isCollapsed = _collapsedSections.contains(secIdx);
          final isModuleComplete = _checkModuleCompletion(
            secIdx,
            curriculum,
            completedIds,
          );
          final isExamCompleted =
              progress.data?.completedExams.contains(section.id) ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                InkWell(
                  onTap: () => _toggleSection(secIdx, curriculum),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            section.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: themeExt.secondaryText,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
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
                if (!isCollapsed)
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
                            final isCompleted = completedIds.contains(
                              lesson.id,
                            );
                            final isLectureLocked = !_isLectureUnlocked(
                              secIdx,
                              lessonIdx,
                              curriculum,
                              progress.data,
                            );
                            final isActive =
                                secIdx == _currentSectionIndex &&
                                lessonIdx == _currentLessonIndex;

                            return InkWell(
                              onTap: isLectureLocked
                                  ? null
                                  : () {
                                      setState(() {
                                        _currentSectionIndex = secIdx;
                                        _currentLessonIndex = lessonIdx;
                                      });
                                    },
                              child: Opacity(
                                opacity: isLectureLocked ? 0.6 : 1.0,
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
                                                    : (isLectureLocked
                                                          ? Icons.lock
                                                          : Icons.play_arrow),
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
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: BoxDecoration(
                                        color: isModuleComplete
                                            ? colorScheme.secondary.withValues(
                                                alpha: 0.2,
                                              )
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
                                                ? (isExamCompleted
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
          );
        },
      ),
    );
  }

  Widget _buildFooter(
    List<ChapterModel> curriculum,
    LectureModel currentLesson,
    List<String> completedIds,
    ProgressModel? progress,
  ) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final isFinalCaseStudy = currentLesson.title.toLowerCase().contains(
      'final case study',
    );
    final isFinalAssignment = currentLesson.title.toLowerCase().contains(
      'final assignment',
    );
    final isLessonCompleted = completedIds.contains(currentLesson.id);

    // Calculate if next is locked
    final currentSection = curriculum[_currentSectionIndex];
    final isLastLessonInSection =
        _currentLessonIndex == currentSection.lectures.length - 1;
    final isLastSection = _currentSectionIndex == curriculum.length - 1;

    bool hasNext = true;
    int nextSecIdx = _currentSectionIndex;
    int nextLessonIdx = _currentLessonIndex;

    if (isLastLessonInSection) {
      if (!isLastSection) {
        nextSecIdx++;
        nextLessonIdx = 0;
      } else {
        hasNext = false;
      }
    } else {
      nextLessonIdx++;
    }

    final isNextLocked =
        !hasNext ||
        !_isLectureUnlocked(nextSecIdx, nextLessonIdx, curriculum, progress);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        // 0,
        MediaQuery.of(context).padding.bottom > 0 ? 0 : 12,
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
            onTap: isNextLocked
                ? null
                : () => _handleNext(isFinalAssignment, curriculum),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isNextLocked
                    ? themeExt.secondaryText.withValues(alpha: 0.3)
                    : const Color(0xFF3B82F6),
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

  String? _resolveMediaUrlForLecture(
    CourseDetailModel course,
    LectureModel currentLecture,
  ) {
    if (currentLecture.muxPlaybackId != null &&
        currentLecture.muxPlaybackId!.isNotEmpty) {
      return 'https://stream.mux.com/${currentLecture.muxPlaybackId}.m3u8';
    }
    if (currentLecture.videoSource?.playbackId != null &&
        currentLecture.videoSource!.playbackId!.isNotEmpty) {
      return 'https://stream.mux.com/${currentLecture.videoSource!.playbackId}.m3u8';
    }
    if (currentLecture.video != null && currentLecture.video!.isNotEmpty) {
      return currentLecture.video;
    }
    if (course.muxPlaybackId != null && course.muxPlaybackId!.isNotEmpty) {
      return 'https://stream.mux.com/${course.muxPlaybackId}.m3u8';
    }
    if (course.videoSource?.playbackId != null &&
        course.videoSource!.playbackId!.isNotEmpty) {
      return 'https://stream.mux.com/${course.videoSource!.playbackId}.m3u8';
    }
    if (course.video != null && course.video!.isNotEmpty) {
      return course.video;
    }
    return null;
  }
}
