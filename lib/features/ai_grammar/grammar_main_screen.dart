import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eduprova/theme/theme_model.dart';
import 'package:eduprova/features/ai_grammar/grammar_conversation_screen.dart';
import 'package:eduprova/features/ai_grammar/widgets/roleplay_section.dart';
import 'package:eduprova/features/ai_grammar/widgets/refiner_section.dart';
import 'package:eduprova/features/ai_grammar/widgets/live_coach_config.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_socket_provider.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_stt_provider.dart';

class GrammarMainScreen extends ConsumerStatefulWidget {
  const GrammarMainScreen({super.key});

  @override
  ConsumerState<GrammarMainScreen> createState() => _GrammarMainScreenState();
}

class _GrammarMainScreenState extends ConsumerState<GrammarMainScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _activeTabIndex = 0;

  // Roleplay Session State
  // Removed local session state as we use GoRouter now

  final List<(String, IconData)> _features = const [
    ('Roleplay', Icons.groups_outlined),
    ('Coach', Icons.lightbulb_outline),
    ('Conversation', Icons.mic_none_outlined),
    ('Refiner', Icons.edit_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _features.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinPracticeMode(0);
    });
  }

  void _handleTabSelection() {
    if (_tabController.index != _activeTabIndex) {
      _joinPracticeMode(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _joinPracticeMode(int index) {
    if (!mounted) return;

    setState(() {
      _activeTabIndex = index;
      if (_tabController.index != index) {
        _tabController.index = index;
      }
    });

    final mode = switch (index) {
      0 => 'roleplay',
      1 => 'live_coach',
      2 => 'conversation',
      3 => 'grammar_refiner',
      _ => 'conversation',
    };

    ref.read(grammarSttProvider.notifier).stopListening();
    ref.read(grammarSocketProvider.notifier).joinPractice(mode);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: themeExt.scaffoldBackgroundColor,
                scrolledUnderElevation: 0,
                leading: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                // title: _buildTabBar(themeExt),
                expandedHeight: 100,
                // title spacing:
                titleSpacing: 42,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // kToolbarHeight + safe area approx 90-100 down to ~56.
                    // A threshold of ~70-80 detects when it's shrunk.
                    final isCollapsed = constraints.maxHeight <= 80;
                    return FlexibleSpaceBar(
                      expandedTitleScale: 1.0,
                      titlePadding: EdgeInsets.only(
                        left: isCollapsed ? 42 : 12,
                      ),
                      background: Container(
                        color: themeExt.scaffoldBackgroundColor,
                      ),
                      title: Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildTabBar(themeExt),
                      ),
                    );
                  },
                ),
                // toolbarHeight: kToolbarHeight + 10,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // 0: Roleplay
              RoleplaySection(
                themeExt: themeExt,
                onStartPractice: (scenario, config) {
                  context.pushNamed(
                    'grammar_roleplay_session',
                    extra: {
                      'title': scenario.title,
                      'difficulty': scenario.difficulty,
                      'roleType': scenario.roleType,
                      'config': config,
                    },
                  );
                },
              ),

              // 1: Coach
              LiveCoachConfigSection(
                themeExt: themeExt,
                onStart: (mode, topic) => context.pushNamed(
                  'grammar_coach_session',
                  extra: {'mode': mode, 'topic': topic},
                ),
              ),

              // 2: Conversation
              const GrammarConversationScreen(),

              // 3: Refiner
              RefinerSection(
                themeExt: themeExt,
                onBack: () => setState(() {
                  _tabController.index = 0;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(AppDesignExtension themeExt) {
    return Material(
      clipBehavior: .antiAlias,
      borderRadius: BorderRadius.circular(30),
      color: themeExt.scaffoldBackgroundColor,
      // margin: const EdgeInsets.only(right: 16),
      // height: 45,
      // decoration: BoxDecoration(
      //   // color: themeExt.scaffoldBackgroundColor,
      //   color: Colors.red,
      //   borderRadius: BorderRadius.circular(30),
      // ),
      child: SizedBox(
        height: 48,
        child: TabBar(
          controller: _tabController,
          onTap: (index) {
            // _joinPracticeMode(index);
          },
          indicator: BoxDecoration(
            // color: const Color(0xFF0066FF),
            gradient: themeExt.buyNowGradient,
            borderRadius: BorderRadius.circular(30),
            // boxShadow: [
            //   BoxShadow(
            //     color: const Color(0xFF0066FF).withValues(alpha: 0.3),
            //     blurRadius: 10,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: themeExt.secondaryText,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          dividerColor: Colors.transparent,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 4,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 24),
          tabs: _features.map((feature) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(feature.$2, size: 20),
                  const SizedBox(width: 8),
                  Text(feature.$1),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
