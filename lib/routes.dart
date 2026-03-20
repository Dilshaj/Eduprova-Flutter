import 'package:eduprova/features/ai_grammar/grammar_home_screen.dart';
import 'package:eduprova/features/ai_grammar/grammar_main_screen.dart';
import 'package:eduprova/features/ai_grammar/screens/grammar_coach_session_screen.dart';
import 'package:eduprova/features/ai_grammar/screens/grammar_roleplay_session_screen.dart';
import 'package:eduprova/features/ai_interview/analytics/interview_analysis.dart';
import 'package:eduprova/features/ai_interview/history/history_analytics_screen.dart';
import 'package:eduprova/features/ai_interview/interview_home/interview_home_screen.dart';
import 'package:eduprova/features/ai_interview/widgets/agent.dart';
import 'package:eduprova/features/ai_interview/widgets/refined_unified_setup_screen.dart';
import 'package:eduprova/features/ai_resume/ai_resume_screen.dart';
import 'package:eduprova/features/ai_resume/screens/import_resume_page.dart';
import 'package:eduprova/features/ai_resume/screens/resume_builder_landing_page.dart';
import 'package:eduprova/features/ai_resume/screens/resume_list_page.dart';
import 'package:eduprova/features/auth/providers/auth_provider.dart';
import 'package:eduprova/features/auth/screens/login_screen.dart';
import 'package:eduprova/features/auth/screens/signup_screen.dart';
import 'package:eduprova/features/courses/screens/billings_payments/billings_payments_screen.dart';
import 'package:eduprova/features/courses/cart/cart_screen.dart';
import 'package:eduprova/features/courses/my_learning/my_learning_screen.dart';
import 'package:eduprova/features/courses/wishlist/my_wishlist_screen.dart';
import 'package:eduprova/features/courses/screens/profile_settings/profile_settings_screen.dart';
import 'package:eduprova/features/help_and_support.dart';
import 'package:eduprova/features/home/main_layout.dart';
import 'package:eduprova/features/home/search/search_screen.dart';
import 'package:eduprova/features/home/storie/view_storie/storie_create_screen.dart';
import 'package:eduprova/features/home/storie/view_storie/storie_users_pager.dart';
import 'package:eduprova/features/jobs/jobs_screen.dart';
import 'package:eduprova/features/jobs/screens/job_details_screen.dart';
import 'package:eduprova/features/jobs/screens/search_jobs_screen.dart';
import 'package:eduprova/features/messages/messages_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/features/home/home_screen.dart';
import 'package:eduprova/features/courses/course_learn/course_learning_screen.dart';
import 'package:eduprova/features/courses/courses_home/courses_screen.dart';
import 'package:eduprova/features/courses/course_detail/course_detail_screen.dart';
// import 'package:eduprova/features/messages/communities/create_channel_screen.dart';
// import 'package:eduprova/features/messages/communities/create_community_screen.dart';
import 'package:eduprova/features/messages_old/messages/chat_screen.dart';
// import 'package:eduprova/features/messages_old/messages/chat_profile_screen.dart';
// import 'package:eduprova/features/messages_old/messages/messages_screen.dart';
// import 'features/auth/providers/auth_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final status = authState.status;
      final isAuth = status == AuthStatus.authenticated;
      final isLoginRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (status == AuthStatus.initial) {
        return AppRoutes.splash;
      }

      if (!isAuth && !isLoginRoute) {
        return AppRoutes.login;
      }

      if (isAuth && isLoginRoute) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const SignupScreen(),
      ),

      /*********************************************
      *************** Bottom Nav Routes ***********
      *********************************************/
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.courses,
                builder: (_, _) => const CoursesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                builder: (_, _) => MessagesShell(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.jobs,
                builder: (_, _) => const JobsScreen(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return JobDetailsScreen(jobId: id);
                    },
                  ),
                  GoRoute(
                    path: 'search',
                    builder: (context, state) => const SearchJobsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(path: AppRoutes.search, builder: (_, _) => const SearchScreen()),
      GoRoute(
        path: AppRoutes.statusPager(':id'),
        builder: (_, state) {
          final initialIndex = state.pathParameters['id']!;
          return StatusUsersPager(initialIndex: int.parse(initialIndex));
        },
      ),
      GoRoute(
        path: AppRoutes.createStory,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const StatusScreen(),
      ),

      /*********************************************
      ******************** Courses  ***************
      *********************************************/
      GoRoute(
        path: AppRoutes.courseDetail(':id'),
        builder: (_, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: AppRoutes.courseLearning(':id'),
        pageBuilder: (_, state) {
          final courseId = state.pathParameters['id']!;
          final query = state.uri.queryParameters;
          final resumeMs = int.tryParse(query['resumeMs'] ?? '');
          final autoplayParam = query['autoplay'];
          final resumeAutoPlay = autoplayParam == null
              ? true
              : autoplayParam == '1';
          return CustomTransitionPage<void>(
            key: state.pageKey,
            opaque: false,
            barrierDismissible: false,
            child: CourseLearningScreen(
              courseId: courseId,
              resumePositionMs: resumeMs,
              resumeAutoPlay: resumeAutoPlay,
              resumeLectureId: query['lectureId'],
              resumeFromMini: query['fromMini'] == '1',
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(path: AppRoutes.myCart, builder: (_, _) => MyCartScreen()),
      GoRoute(
        path: AppRoutes.myWishlist,
        builder: (_, _) => MyWishlistScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpAndSupport,
        builder: (_, _) => HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.myLearning,
        builder: (_, _) => MyLearningScreen(),
      ),
      GoRoute(
        path: AppRoutes.billingAndPayments,
        builder: (_, _) => BillingPaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSettings,
        builder: (_, _) => ProfileSettingsScreen(),
      ),

      /*********************************************
      ***************** Messages  *****************
      // *********************************************/
      // GoRoute(
      //   path: AppRoutes.createCommunity,
      //   builder: (_, _) => const CreateCommunityScreen(),
      // ),
      // GoRoute(
      //   path: AppRoutes.createChannel,
      //   builder: (_, _) => const CreateChannelScreen(),
      // ),
      GoRoute(
        path: AppRoutes.chat(':id'),
        builder: (_, state) {
          final chatId = state.pathParameters['id']!;
          return ChatScreen(conversationId: chatId);
        },
      ),
      // GoRoute(
      //   path: '/contact/:id',
      //   builder: (_, state) {
      //     final contactId = state.pathParameters['id']!;
      //     return ChatProfileScreen(id: contactId);
      //   },
      // ),

      /*********************************************
      ***************  Ai Interview  ***************
      *********************************************/
      GoRoute(
        path: AppRoutes.aiInterview,
        builder: (context, state) => const AiInterviewHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiInterviewSetup,
        builder: (_, _) =>
            const RefinedUnifiedInterviewSetupPage(initialTabIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.aiResumeInterview,
        builder: (_, _) =>
            const RefinedUnifiedInterviewSetupPage(initialTabIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.interviewHistory,
        builder: (_, _) => const HistoryAnalyticsScreen(initialTabIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.interviewAnalytics,
        builder: (_, _) => const HistoryAnalyticsScreen(initialTabIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.interviewFeedback(':id'),
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return InterviewAnalysisPage(sessionId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.interviewLiveAgent,
        builder: (_, _) => const LiveAgentPage(
          sessionId: 'dummy_session',
          role: 'Career Coach',
        ),
      ),

      /*********************************************
      *************  Ai Resume Builder  ************
      *********************************************/
      GoRoute(
        path: AppRoutes.resumeBuilderHome,
        builder: (_, _) => const ResumeBuilderLandingPage(),
      ),
      GoRoute(
        path: AppRoutes.resumeBuilderList,
        builder: (_, _) => const ResumeListPage(),
      ),
      GoRoute(
        path: AppRoutes.resumeBuilderImport,
        builder: (_, _) => const ImportResumePage(),
      ),
      GoRoute(
        path: AppRoutes.resumeBuilderEditor(':id'),
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AiResumeScreen(resumeId: id);
        },
      ),

      /*********************************************
      *************  Ai Grammar  ************
      *********************************************/
      GoRoute(
        name: 'grammar',
        path: AppRoutes.grammar,
        builder: (_, _) => const GrammarHomeScreen(),
        routes: [
          GoRoute(
            name: 'grammar_conversation',
            path: 'conversation', // Nested path
            builder: (_, _) => const GrammarMainScreen(),
          ),
          GoRoute(
            name: 'grammar_roleplay_session',
            path: 'roleplay/session',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return GrammarRoleplaySessionScreen(
                title: extra['title'] as String,
                difficulty: extra['difficulty'] as String,
                roleType: extra['roleType'] as String,
                config: extra['config'] as Map<String, dynamic>?,
              );
            },
          ),
          GoRoute(
            name: 'grammar_coach_session',
            path: 'coach/session',
            builder: (_, _) => const GrammarCoachSessionScreen(),
          ),
        ],
      ),
    ],
  );
});
