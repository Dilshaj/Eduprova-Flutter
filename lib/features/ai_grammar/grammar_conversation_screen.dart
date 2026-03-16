import 'package:eduprova/features/ai_grammar/widgets/roleplay_section.dart';
import 'package:eduprova/features/ai_grammar/widgets/active_roleplay_session.dart';
import 'package:eduprova/features/ai_grammar/widgets/shadowing_section.dart';
import 'package:eduprova/features/ai_grammar/widgets/coach_section.dart';
import 'package:eduprova/features/ai_grammar/widgets/refiner_section.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:eduprova/features/ai_grammar/providers/grammar_audio_player_provider.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_socket_provider.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_stt_provider.dart';

class GrammarConversationScreen extends ConsumerStatefulWidget {
  const GrammarConversationScreen({super.key});

  @override
  ConsumerState<GrammarConversationScreen> createState() =>
      _GrammarConversationScreenState();
}

class _GrammarConversationScreenState
    extends ConsumerState<GrammarConversationScreen>
    with TickerProviderStateMixin {
  final ScrollController _transcriptScrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  late AnimationController _pulseController;

  bool _isTypeMode = false;
  bool? _isCorrect;
  double _fadeOpacity = 0.0;
  int _activeTabIndex = 0;
  final List<GlobalKey> _tabKeys = List.generate(5, (index) => GlobalKey());
  double _indicatorLeft = 20;
  double _indicatorWidth = 0;
  int? _hoverTabIndex;
  double _hoverLeft = 0;
  double _hoverWidth = 0;
  bool _isHovering = false;

  // Roleplay Session State
  RoleplayScenario? _selectedScenario;
  Map<String, dynamic>? _selectedConfig;
  bool _isSessionActive = false;

  final List<(String, IconData)> _features = const [
    ('Conversation', Icons.mic_none_outlined),
    ('Coach', Icons.lightbulb_outline),
    ('Refiner', Icons.edit_outlined),
    ('Shadowing', Icons.record_voice_over_outlined),
    ('Roleplay', Icons.groups_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _transcriptScrollController.addListener(() {
      final newOpacity = _transcriptScrollController.offset > 5 ? 1.0 : 0.0;
      if (_fadeOpacity != newOpacity) {
        setState(() => _fadeOpacity = newOpacity);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicator();
      // Initialize socket for the default tab
      _joinPracticeMode(0);
    });
  }

  void _joinPracticeMode(int index) {
    final mode = switch (index) {
      0 => 'conversation',
      1 => 'live_coach',
      2 => 'grammar_refiner',
      3 => 'shadowing',
      4 => 'roleplay',
      _ => 'conversation',
    };

    // Reset socket and join new practice mode
    ref.read(grammarSocketProvider.notifier).joinPractice(mode);
  }

  void _updateIndicator() {
    final key = _tabKeys[_activeTabIndex];
    final context = key.currentContext;
    if (context == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final RenderBox? stackBox = context
        .findAncestorRenderObjectOfType<RenderStack>();
    if (stackBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero, ancestor: stackBox);
    setState(() {
      _indicatorLeft = position.dx;
      _indicatorWidth = renderBox.size.width;
    });
  }

  void _onTabTap(int index) {
    setState(() {
      _activeTabIndex = index;
    });
    _updateIndicatorPosition();
    _joinPracticeMode(index);
  }

  void _updateIndicatorPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _tabKeys[_activeTabIndex];
      final context = key.currentContext;
      if (context != null) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final RenderBox stackBox = context
            .findAncestorRenderObjectOfType<RenderStack>()!;
        final position = box.localToGlobal(Offset.zero, ancestor: stackBox);
        setState(() {
          _indicatorLeft = position.dx;
          _indicatorWidth = box.size.width;
        });
      }
    });
  }

  void _onHover(int index) {
    if (_activeTabIndex == index) {
      if (_isHovering) setState(() => _isHovering = false);
      return;
    }
    setState(() {
      _hoverTabIndex = index;
      _isHovering = true;
    });
    _updateHoverPosition();
  }

  void _updateHoverPosition() {
    if (_hoverTabIndex == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _tabKeys[_hoverTabIndex!];
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final stackBox = context.findAncestorRenderObjectOfType<RenderStack>()!;
        final position = box.localToGlobal(Offset.zero, ancestor: stackBox);
        setState(() {
          _hoverLeft = position.dx;
          _hoverWidth = box.size.width;
        });
      }
    });
  }

  void _clearInput() {
    setState(() {
      _textController.clear();
      _isCorrect = null;
    });
  }

  void _checkAnswer(String input, String currentQuestion) {
    if (input.isEmpty) return;

    final normalizedInput = input.trim().toLowerCase().replaceAll(
      RegExp(r'[^\w\s]'),
      '',
    );
    final normalizedTarget = currentQuestion.trim().toLowerCase().replaceAll(
      RegExp(r'[^\w\s]'),
      '',
    );

    setState(() {
      _isCorrect = normalizedInput == normalizedTarget;
    });

    // Reset after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isCorrect = null);
    });
  }

  /*
  void _scrollToBottom() {
    ...
  }
  */

  /*
  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    ...
  }
  */

  /*
  Future<void> _initSpeech() async {
    await _speechToText.initialize();
  }
  */

  /* Removed legacy logic */

  @override
  void dispose() {
    // _flutterTts.stop();
    // _speechToText.stop();
    _transcriptScrollController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final socketState = ref.watch(grammarSocketProvider);
    final isAiSpeakingAudibly = ref.watch(grammarAudioPlayerProvider);
    final sttState = ref.watch(grammarSttProvider);
    final isAiActive = socketState.isAiSpeaking || isAiSpeakingAudibly;

    // Get last AI message for "current question"
    final lastAiMsg = socketState.messages.reversed.firstWhere(
      (m) => m.role == 'ai' && m.text.isNotEmpty,
      orElse: () => GrammarMessage(
        role: 'ai',
        text: "Initializing practice session...",
      ),
    );
    final currentQuestion = lastAiMsg.text;

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isSessionActive && _selectedScenario != null
            ? ActiveRoleplaySession(
                title: _selectedScenario!.title,
                difficulty: _selectedScenario!.difficulty,
                roleType: _selectedScenario!.roleType,
                themeExt: themeExt,
                config: _selectedConfig,
                onBack: () => setState(() => _isSessionActive = false),
              )
            : Column(
                children: [
                  _buildHeader(context, colorScheme),
                  if (_activeTabIndex != 4 &&
                      _activeTabIndex != 3 &&
                      _activeTabIndex != 1 &&
                      _activeTabIndex != 2)
                    _buildFeatureTabs(themeExt),
                  Expanded(
                    child: _activeTabIndex == 4
                        ? RoleplaySection(
                            themeExt: themeExt,
                            onStartPractice: (scenario, config) {
                              setState(() {
                                _selectedScenario = scenario;
                                _selectedConfig = config;
                                _isSessionActive = true;
                              });
                            },
                          )
                        : _activeTabIndex == 3
                        ? ShadowingSection(
                            themeExt: themeExt,
                            onBack: () => setState(() => _activeTabIndex = 0),
                          )
                        : _activeTabIndex == 1
                        ? CoachSection(
                            themeExt: themeExt,
                            onBack: () => setState(() => _activeTabIndex = 0),
                          )
                        : _activeTabIndex == 2
                        ? RefinerSection(
                            themeExt: themeExt,
                            onBack: () => setState(() => _activeTabIndex = 0),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                _buildQuestionSection(
                                  colorScheme,
                                  themeExt,
                                  lastAiMsg,
                                  isAiActive,
                                ),
                                _buildVoiceInteractionHub(
                                  colorScheme,
                                  themeExt,
                                  sttState,
                                  socketState,
                                  currentQuestion,
                                  isAiActive,
                                ),
                                _buildAnalysisSection(colorScheme, themeExt),
                                _buildResponseRefinementSection(
                                  colorScheme,
                                  themeExt,
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    if (_activeTabIndex == 4 ||
        _activeTabIndex == 3 ||
        _activeTabIndex == 5 ||
        _activeTabIndex == 1 ||
        _activeTabIndex == 2) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Circle Back Button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _activeTabIndex = 0),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: themeExt.cardColor,
                    border: Border.all(color: themeExt.borderColor),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeExt.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            // Centered Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _activeTabIndex == 4
                        ? Icons.psychology_outlined
                        : (_activeTabIndex == 3
                              ? Icons.record_voice_over_outlined
                              : (_activeTabIndex == 1
                                    ? Icons.bolt
                                    : Icons.auto_awesome_outlined)),
                    size: 20,
                    color: const Color(0xFF0066FF),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _activeTabIndex == 4
                        ? 'Roleplay'
                        : (_activeTabIndex == 3
                              ? 'Shadowing'
                              : (_activeTabIndex == 1
                                    ? 'LIVE INTELLIGENCE'
                                    : 'AI TEXT REFINER')),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // Circle Search Button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  border: Border.all(color: themeExt.borderColor),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: themeExt.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.search,
                  size: 24,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.account_circle_outlined,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTabs(AppDesignExtension themeExt) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 50,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Hover Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: _hoverLeft,
                width: _hoverWidth,
                height: 44,
                top: 3,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isHovering ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              // Sliding Indicator (Active)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                left: _indicatorLeft,
                width: _indicatorWidth,
                height: 44,
                top: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var (i, feature) in _features.indexed) ...[
                    _buildTab(
                      feature.$1,
                      feature.$2,
                      _activeTabIndex == i,
                      i,
                      themeExt,
                    ),
                    if (i < _features.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    String label,
    IconData icon,
    bool isActive,
    int index,
    AppDesignExtension themeExt,
  ) {
    return MouseRegion(
      key: _tabKeys[index],
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHover(index),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          _onTabTap(index);
          setState(() => _isHovering = false);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : themeExt.secondaryText,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : themeExt.secondaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSection(
    ColorScheme colorScheme,
    AppDesignExtension themeExt,
    GrammarMessage lastAiMsg,
    bool isAiSpeaking,
  ) {
    final currentQuestion = lastAiMsg.text;
    if (isAiSpeaking && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!isAiSpeaking && _pulseController.isAnimating) {
      _pulseController.stop();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeExt.borderColor),
        boxShadow: [
          BoxShadow(
            color: themeExt.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentQuestion,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Practice speaking naturally and improve your grammar and fluency.',
            style: TextStyle(
              fontSize: 16,
              color: themeExt.secondaryText,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if (lastAiMsg.audio != null) {
                        ref
                            .read(grammarAudioPlayerProvider.notifier)
                            .playBase64(lastAiMsg.audio!);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0066FF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isAiSpeaking
                              ? _buildVoiceWaves()
                              : const Icon(
                                  Icons.volume_up_outlined,
                                  color: Colors.white,
                                ),
                          const SizedBox(width: 12),
                          Text(
                            isAiSpeaking ? 'Speaking...' : 'Listen',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () {
                    ref
                        .read(grammarSocketProvider.notifier)
                        .refreshConversationQuestion();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeExt.borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.refresh, color: themeExt.secondaryText),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceWaves() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [for (int i = 0; i < 4; i++) _buildWaveBar(i)],
        );
      },
    );
  }

  Widget _buildWaveBar(int index) {
    // stagger the heights based on the pulse controller
    final double value = _pulseController.value;
    final double height =
        10 +
        (15 * (0.5 + 0.5 * math.sin((value * 2 * math.pi) + (index * 0.8))));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildVoiceInteractionHub(
    ColorScheme colorScheme,
    AppDesignExtension themeExt,
    GrammarSttState sttState,
    GrammarSocketState socketState,
    String currentQuestion,
    bool isAiActive,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: themeExt.borderColor),
        boxShadow: [
          BoxShadow(
            color: themeExt.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isTypeMode) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () =>
                    ref.read(grammarSttProvider.notifier).toggleListening(),
                child: _buildStaticMic(sttState.isListening),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (Rect rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _fadeOpacity > 0 ? Colors.transparent : Colors.black,
                          Colors.black,
                        ],
                        stops: const [0.0, 0.15],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: GestureDetector(
                        onTap: isAiActive
                            ? null
                            : () {
                                if (sttState.isListening) {
                                  ref
                                      .read(grammarSttProvider.notifier)
                                      .stopListening();
                                } else {
                                  ref
                                      .read(grammarSttProvider.notifier)
                                      .startListening();
                                }
                              },
                        child: SingleChildScrollView(
                          controller: _transcriptScrollController,
                          physics: const ClampingScrollPhysics(),
                          child: Text(
                            sttState.isListening
                                ? (sttState.transcript.isEmpty
                                      ? 'Listening...'
                                      : sttState.transcript)
                                : (sttState.transcript.isEmpty
                                      ? 'Tap Mic to Speak'
                                      : sttState.transcript),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: sttState.isListening
                                  ? const Color(0xFF0066FF)
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isCorrect != null) _buildValidationBadge(),
                  if (sttState.transcript.isNotEmpty && !sttState.isListening)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _clearInput,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: themeExt.borderColor.withValues(
                                alpha: 0.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: themeExt.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeExt.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeExt.borderColor),
              ),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type the sentence here...',
                      hintStyle: TextStyle(color: themeExt.secondaryText),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) => _checkAnswer(val, currentQuestion),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_textController.text.isNotEmpty)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _clearInput,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.close,
                                color: themeExt.secondaryText,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      _buildSendButton(currentQuestion),
                    ],
                  ),
                ],
              ),
            ),
            if (_isCorrect != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildValidationBadge(),
              ),
          ],
          const SizedBox(height: 24),
          _buildModeToggle(themeExt, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStaticMic(bool isListening) {
    if (isListening) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0066FF).withValues(alpha: 0.1),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: themeExt.cardColor,
            boxShadow: [
              BoxShadow(
                color: themeExt.shadowColor,
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.mic, color: Color(0xFF0066FF), size: 36),
        ),
      ],
    );
  }

  Widget _buildModeToggle(
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: themeExt.borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _isTypeMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: !_isTypeMode ? themeExt.cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: !_isTypeMode
                      ? [BoxShadow(color: themeExt.shadowColor, blurRadius: 5)]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mic_none_outlined,
                      size: 18,
                      color: !_isTypeMode
                          ? const Color(0xFF0066FF)
                          : themeExt.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Speak',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !_isTypeMode
                            ? const Color(0xFF0066FF)
                            : themeExt.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _isTypeMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isTypeMode ? themeExt.cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: _isTypeMode
                      ? [BoxShadow(color: themeExt.shadowColor, blurRadius: 5)]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_outlined,
                      size: 18,
                      color: _isTypeMode
                          ? const Color(0xFF0066FF)
                          : themeExt.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isTypeMode
                            ? const Color(0xFF0066FF)
                            : themeExt.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationBadge() {
    final bool correct = _isCorrect ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (correct ? const Color(0xFF22C55E) : const Color(0xFFEF4444))
                .withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            correct ? Icons.check_circle_outline : Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            correct ? 'Correct! Well done' : 'Almost there! Try again',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(String currentQuestion) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _checkAnswer(_textController.text, currentQuestion),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFF0066FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(
    ColorScheme colorScheme,
    AppDesignExtension themeExt,
  ) {
    final socketState = ref.watch(grammarSocketProvider);
    final feedback = socketState.lastFeedback;
    final scores = socketState.lastScores;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF0066FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Real-time Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (feedback != null)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _showFeedbackDialog(feedback),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'AI FEEDBACK',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: themeExt.successBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: themeExt.successColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMetricsCard(themeExt, colorScheme, scores),
          const SizedBox(height: 24),
          if (feedback != null) ...[
            Text(
              'AI SUGGESTIONS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: themeExt.secondaryText,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (feedback['grammarFix'] != null)
              _buildSuggestionCard(
                'Grammar Fix: ${feedback['grammarFix']}',
                Icons.check_circle_outline,
                const Color(0xFF22C55E),
                themeExt,
                colorScheme,
              ),
            if (feedback['betterWay'] != null) ...[
              const SizedBox(height: 12),
              _buildSuggestionCard(
                'Better Way: ${feedback['betterWay']}',
                Icons.lightbulb_outline,
                const Color(0xFF0066FF),
                themeExt,
                colorScheme,
              ),
            ],
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'Speak to see real-time corrections and metrics',
                  style: TextStyle(
                    color: themeExt.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
    Map<String, dynamic>? scores,
  ) {
    final grammarVal = (scores?['grammar'] ?? 0).toDouble() / 100.0;
    final fluencyVal = (scores?['fluency'] ?? 0).toDouble() / 100.0;
    final vocabularyVal = (scores?['vocabulary'] ?? 0).toDouble() / 100.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeExt.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CORE METRICS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeExt.secondaryText,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildMetricRow(
            'Grammar',
            grammarVal > 0 ? grammarVal : 0.0,
            const Color(0xFF22C55E),
            colorScheme,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Fluency',
            fluencyVal > 0 ? fluencyVal : 0.0,
            const Color(0xFF3B82F6),
            colorScheme,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Vocabulary',
            vocabularyVal > 0 ? vocabularyVal : 0.0,
            const Color(0xFF9333EA),
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    double value,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(
    String text,
    IconData icon,
    Color color,
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text.rich(
              _styleSuggestionText(text, color),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _styleSuggestionText(String text, Color color) {
    final parts = text.split(':');
    if (parts.length < 2) return TextSpan(text: text);
    return TextSpan(
      children: [
        TextSpan(
          text: '${parts[0]}:',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        TextSpan(
          text: parts.skip(1).join(':'),
        ),
      ],
    );
  }

  Widget _buildResponseRefinementSection(
    ColorScheme colorScheme,
    AppDesignExtension themeExt,
  ) {
    final socketState = ref.watch(grammarSocketProvider);
    final lastUserMsg = socketState.messages.reversed.firstWhere(
      (m) => m.role == 'user',
      orElse: () => GrammarMessage(role: 'user', text: ''),
    );

    if (lastUserMsg.text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'RESPONSE REFINEMENT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeExt.secondaryText,
                  letterSpacing: 1.2,
                ),
              ),
              if (lastUserMsg.feedback != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showFeedbackDialog(lastUserMsg.feedback!),
                  icon: const Icon(
                    Icons.auto_awesome,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildRefinementHeader('ORIGINAL TRANSCRIPT', themeExt),
          const SizedBox(height: 8),
          _buildTranscriptCard('"${lastUserMsg.text}"', themeExt),
          if (lastUserMsg.feedback != null) ...[
            const SizedBox(height: 24),
            _buildRefinementHeader(
              'IMPROVED RESPONSE',
              themeExt,
              isPrimary: true,
            ),
            const SizedBox(height: 8),
            _buildImprovedCard(
              '"${lastUserMsg.feedback!['betterWay'] ?? lastUserMsg.feedback!['grammarFix'] ?? ''}"',
              colorScheme,
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showFeedbackDialog(Map<String, dynamic> feedback) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Grammar Feedback',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (feedback['grammarFix'] != null) ...[
                const Text(
                  'CORRECTED VERSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3B82F6),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    feedback['grammarFix'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (feedback['betterWay'] != null) ...[
                const Text(
                  'BETTER PHRASING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    feedback['betterWay'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    foregroundColor: const Color(0xFF3B82F6),
                  ),
                  child: const Text(
                    'GOT IT',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefinementHeader(
    String title,
    AppDesignExtension themeExt, {
    bool isPrimary = false,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isPrimary ? const Color(0xFF0066FF) : themeExt.secondaryText,
      ),
    );
  }

  Widget _buildTranscriptCard(String text, AppDesignExtension themeExt) {
    return Container(
      padding: .all(20),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: .circular(20),
        border: .all(color: themeExt.borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: themeExt.secondaryText,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImprovedCard(String text, ColorScheme colorScheme) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => ref
            .read(grammarSocketProvider.notifier)
            .correctSentence(text, 'user'),
        child: Container(
          padding: .all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF).withValues(alpha: 0.05),
            borderRadius: .circular(20),
            border: .all(color: const Color(0xFF0066FF).withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: Color(0xFF0066FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Tap to listen',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0066FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text.rich(
                _styleImprovedText(text),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _styleImprovedText(String text) {
    return TextSpan(text: text);
  }
}
