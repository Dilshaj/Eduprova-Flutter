import 'package:eduprova/features/courses/core/models/course_detail_model.dart';
import 'package:eduprova/features/courses/widgets/video_player.dart';
import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';

// Assuming these paths match the generated dart files structure
import '../course_learn/tabs/ask_doubts_screen.dart';
import '../course_learn/tabs/practice_screen.dart';
import '../course_learn/tabs/notes_screen.dart';
import '../course_learn/tabs/resources_screen.dart';
import '../course_learn/tabs/messages_screen.dart';

class CourseContinueScreen extends StatefulWidget {
  const CourseContinueScreen({super.key});

  @override
  State<CourseContinueScreen> createState() => _CourseContinueScreenState();
}

class _CourseContinueScreenState extends State<CourseContinueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  int _activeTabIndex = 0;
  bool _isLoading = true;
  bool _isMini = false;
  bool _isFullScreen = false;
  late double _videoHeight;

  int _currentSectionIndex = 0;
  int _currentLessonIndex = 0;
  List<int> _completedLessonIds = [];
  final List<int> _collapsedSections = [1, 2];
  Map<int, String> _moduleExamStatus = {0: 'open', 1: 'locked', 2: 'locked'};
  List<int> _unlockedModules = [0];

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'MODULE 1: FOUNDATIONS',
      'lessons': [
        {'id': 1, 'title': 'Architecture and Vision', 'duration': '08:45'},
        {'id': 2, 'title': 'Setting the Environment', 'duration': '12:20'},
        {'id': 3, 'title': 'First Deployment Steps', 'duration': '15:10'},
      ],
    },
    {
      'title': 'MODULE 2: ADVANCED LOGIC',
      'lessons': [
        {'id': 4, 'title': 'Workflow Management', 'duration': '22:30'},
        {'id': 5, 'title': 'State & Concurrency', 'duration': '18:15'},
      ],
    },
    {
      'title': 'MODULE 3: PROJECT CERTIFICATION',
      'lessons': [
        {'id': 6, 'title': 'Final Case Study', 'duration': 'VIDEO • 15:10'},
        {
          'id': 7,
          'title': 'Final Assignment',
          'duration': 'ASSIGNMENT • 15:00',
        },
      ],
    },
  ];

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
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigationArgs();
    });
  }

  void _handleNavigationArgs() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('targetSectionIndex')) {
      final targetSec = args['targetSectionIndex'] as int;
      final targetLes = args['targetLessonIndex'] as int? ?? 0;

      setState(() {
        _currentSectionIndex = targetSec;
        _currentLessonIndex = targetLes;
        _unlockedModules = [0, 1, 2];

        _collapsedSections.remove(targetSec);

        _moduleExamStatus = {0: 'completed', 1: 'completed', 2: 'open'};

        _completedLessonIds = [1, 2, 3, 4, 5, 6];

        if (args['assessmentSubmitted'] == true) {
          if (!_completedLessonIds.contains(7)) {
            _completedLessonIds.add(7);
          }
        }
      });
    }
  }

  void _handleVideoBackPress() {
    if (_activeTabIndex != 0) {
      _mainTabController.animateTo(0);
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/coursesOptions',
          arguments: {'tab': 'Ongoing'},
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

  bool _checkModuleCompletion(int sectionIndex) {
    final section = _sections[sectionIndex];
    final lessons = section['lessons'] as List;
    return lessons.every((l) => _completedLessonIds.contains(l['id']));
  }

  void _handleModuleExamClick(int sectionIndex) {
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
                if (sectionIndex + 1 < _sections.length) {
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
    Map<String, dynamic> currentLesson,
    bool isFinalAssignment,
  ) {
    if (isFinalAssignment) {
      Navigator.pushNamed(context, '/securityCheck');
      return;
    }

    if (!_completedLessonIds.contains(currentLesson['id'])) {
      setState(() {
        _completedLessonIds.add(currentLesson['id']);
      });
    }
  }

  void _handleNext(bool isFinalAssignment) {
    if (isFinalAssignment) {
      Navigator.pushNamed(context, '/securityCheck');
      return;
    }

    final currentSection = _sections[_currentSectionIndex];
    final lessons = currentSection['lessons'] as List;
    final isLastLessonInSection = _currentLessonIndex == lessons.length - 1;
    final isLastSection = _currentSectionIndex == _sections.length - 1;

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

  void _handlePrev() {
    if (_currentLessonIndex > 0) {
      setState(() {
        _currentLessonIndex--;
      });
    } else if (_currentSectionIndex > 0) {
      final prevSectionIndex = _currentSectionIndex - 1;
      final prevSectionLessons = _sections[prevSectionIndex]['lessons'] as List;
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
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleVideoBackPress();
      },
      child: Scaffold(
        backgroundColor: themeExt.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Video Layer
            if (!_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _isFullScreen
                    ? MediaQuery.of(context).size.height
                    : _videoHeight,
                child: CourseVideoPlayer(
                  videoUrl:
                      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
                  onBackPress: _handleVideoBackPress,
                  onMiniPlayerChange: (isMini) =>
                      setState(() => _isMini = isMini),
                  onFullscreenChange: (isFull) =>
                      setState(() => _isFullScreen = isFull),
                ),
              ),

            // Content Layer
            if (!_isFullScreen)
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: _isMini
                          ? 0
                          : _videoHeight - MediaQuery.of(context).padding.top,
                    ),

                    if (_isLoading)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      Expanded(child: _buildContentArea()),
                  ],
                ),
              ),

            // Footer Navigation
            if (!_isFullScreen &&
                !_isMini &&
                _activeTabIndex == 0 &&
                !_isLoading)
              Positioned(bottom: 0, left: 0, right: 0, child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final currentSection = _sections[_currentSectionIndex];
    final currentLesson =
        (currentSection['lessons'] as List)[_currentLessonIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: themeExt.borderColor)),
            color: themeExt.scaffoldBackgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentLesson['title'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${currentSection['title'].split(':')[0]} • SECTION ${_currentLessonIndex + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: themeExt.borderColor)),
            color: themeExt.scaffoldBackgroundColor,
          ),
          child: TabBar(
            controller: _mainTabController,
            isScrollable: true,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: colorScheme.primary,
            unselectedLabelColor: themeExt.secondaryText,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _mainTabController,
            children: [
              _buildLessonsList(),
              const AskDoubtsScreen(courseId: ''),
              const PracticeScreen(),
              const NotesScreen(),
              ResourcesScreen(
                resources: (_sections as List)
                    .expand((s) {
                      final lessons = (s as Map)['lessons'] as List? ?? [];
                      return lessons.expand((l) {
                        final attachments =
                            (l as Map)['attachments'] as List? ?? [];
                        return attachments.map(
                          (a) => AttachmentModel.fromJson(
                            a as Map<String, dynamic>,
                          ),
                        );
                      });
                    })
                    .toList()
                    .cast<AttachmentModel>(),
              ),
              const MessagesScreen(courseId: ''),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLessonsList() {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: themeExt.scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: _sections.length,
        itemBuilder: (context, secIdx) {
          final section = _sections[secIdx];
          final isCollapsed = _collapsedSections.contains(secIdx);
          final isLocked = !_unlockedModules.contains(secIdx);
          final isModuleComplete = _checkModuleCompletion(secIdx);
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
                          Text(
                            '${section['title']} ${isLocked ? '🔒' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: themeExt.secondaryText,
                              letterSpacing: 1.1,
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
                      child: Column(
                        children: [
                          ...((section['lessons'] as List).asMap().entries.map((
                            entry,
                          ) {
                            final lessonIdx = entry.key;
                            final lesson = entry.value;
                            final isCompleted = _completedLessonIds.contains(
                              lesson['id'],
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
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? themeExt.successBackgroundColor
                                            : (isActive
                                                  ? colorScheme.primary
                                                  : themeExt.skeletonBase),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: isCompleted
                                          ? Icon(
                                              Icons.check,
                                              size: 16,
                                              color: themeExt.successColor,
                                            )
                                          : Icon(
                                              Icons.play_arrow,
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
                                            lesson['title'],
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
                                            lesson['duration'],
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
                          if (secIdx != 2)
                            InkWell(
                              onTap: isModuleComplete
                                  ? () => _handleModuleExamClick(secIdx)
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final currentSection = _sections[_currentSectionIndex];
    final currentLesson =
        (currentSection['lessons'] as List)[_currentLessonIndex];
    final isFinalCaseStudy = currentLesson['title'].contains(
      'Final Case Study',
    );
    final isFinalAssignment = currentLesson['title'].contains(
      'Final Assignment',
    );
    final isLessonCompleted = _completedLessonIds.contains(currentLesson['id']);

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
            onTap: _handlePrev,
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
                                : [colorScheme.primary, colorScheme.secondary]),
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
            onTap: () => _handleNext(isFinalAssignment),
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
