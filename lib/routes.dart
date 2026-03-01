import 'package:eduprova/auth/login_screen.dart';
import 'package:eduprova/features/courses/screens/billings_payments/billings_payments_screen.dart';
import 'package:eduprova/features/courses/screens/my_learning/my_learning_screen.dart';
import 'package:eduprova/features/courses/screens/my_wishlist_screen.dart';
import 'package:eduprova/features/courses/screens/profile_settings/profile_settings_screen.dart';
import 'package:eduprova/features/help_and_support.dart';
import 'package:eduprova/features/home/main_layout.dart';
import 'package:eduprova/features/home/search/search_screen.dart';
import 'package:eduprova/features/home/storie/view_storie/storie_create_screen.dart';
import 'package:eduprova/features/home/storie/view_storie/storie_users_pager.dart';
import 'package:eduprova/features/jobs/jobs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/features/home/home_screen.dart';
import 'package:eduprova/features/courses/screens/course_learn/course_learning_screen.dart';
import 'package:eduprova/features/courses/screens/courses_screen.dart';
import 'package:eduprova/features/courses/screens/course_detail_screen.dart';
import 'package:eduprova/features/messages/communities/create_channel_screen.dart';
import 'package:eduprova/features/messages/communities/create_community_screen.dart';
import 'package:eduprova/features/messages/messages/chat_screen.dart';
import 'package:eduprova/features/messages/messages/chat_profile_screen.dart';
import 'package:eduprova/features/messages/messages/messages_screen.dart';

// SplashScreen and Auth imports (only necessary ones)
import 'features/auth/providers/auth_provider.dart';
// import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

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
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Bottom Nav Routes
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.courses,
                builder: (context, state) => const CoursesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                builder: (context, state) => const MessagesListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jobs',
                builder: (context, state) => const JobsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/status/:id',
        builder: (context, state) {
          final initialIndex = state.pathParameters['id']!;
          return StatusUsersPager(initialIndex: int.parse(initialIndex));
        },
      ),
      GoRoute(
        path: AppRoutes.createStory,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StatusScreen(),
      ),

      //// Course Routes
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/course/:id/learn',
        pageBuilder: (context, state) {
          final courseId = state.pathParameters['id']!;
          final resumeMs = int.tryParse(
            state.uri.queryParameters['resumeMs'] ?? '',
          );
          final resumeLectureId = state.uri.queryParameters['lectureId'];
          final resumeFromMini = state.uri.queryParameters['fromMini'] == '1';
          final autoplayParam = state.uri.queryParameters['autoplay'];
          final resumeAutoPlay = autoplayParam == null ? true : autoplayParam == '1';
          return CustomTransitionPage<void>(
            key: state.pageKey,
            opaque: false,
            barrierDismissible: false,
            child: CourseLearningScreen(
              courseId: courseId,
              resumePositionMs: resumeMs,
              resumeAutoPlay: resumeAutoPlay,
              resumeLectureId: resumeLectureId,
              resumeFromMini: resumeFromMini,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myCart,
        builder: (context, state) {
          return MyWishlistScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.myWishlist,
        builder: (context, state) {
          return MyWishlistScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.helpAndSupport,
        builder: (context, state) {
          return HelpSupportScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.myLearning,
        builder: (context, state) {
          return MyLearningScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.billingAndPayments,
        builder: (context, state) {
          return BillingPaymentsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.profileSettings,
        builder: (context, state) {
          return ProfileSettingsScreen();
        },
      ),

      //// Messages Routes
      GoRoute(
        path: AppRoutes.createCommunity,
        builder: (context, state) => const CreateCommunityScreen(),
      ),
      GoRoute(
        path: AppRoutes.createChannel,
        builder: (context, state) => const CreateChannelScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          return ChatScreen(id: chatId);
        },
      ),
      GoRoute(
        path: '/contact/:id',
        builder: (context, state) {
          final contactId = state.pathParameters['id']!;
          return ChatProfileScreen(id: contactId);
        },
      ),
    ],
  );
});
