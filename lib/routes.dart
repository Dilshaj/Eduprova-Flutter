import 'package:edupurva/features/home/status/status_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edupurva/core/navigation/app_routes.dart';
import 'package:edupurva/features/home/home_screen.dart';
import 'package:edupurva/features/home/search_screen.dart';
import 'package:edupurva/features/courses/screens/courses_screen.dart';
import 'package:edupurva/features/courses/screens/course_detail_screen.dart';
import 'package:edupurva/features/messages/communities/create_channel_screen.dart';
import 'package:edupurva/features/messages/communities/create_community_screen.dart';
import 'package:edupurva/features/messages/messages/chat_screen.dart';
import 'package:edupurva/features/messages/messages/chat_profile_screen.dart';
import 'package:edupurva/features/messages/messages/messages_screen.dart';
import 'package:edupurva/features/home/main_layout.dart';
import 'package:edupurva/features/home/jobs_screen.dart';

// SplashScreen and Auth imports (only necessary ones)
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
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
        path: AppRoutes.createStory,
        builder: (context, state) => const StatusScreen(),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
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
