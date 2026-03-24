import 'package:eduprova/core/notifications/push_notification_service.dart';
import 'package:eduprova/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eduprova/globals.dart' show prefs;
import 'package:eduprova/routes.dart';
import 'package:eduprova/features/auth/providers/auth_provider.dart';
import 'package:eduprova/features/messages_old/providers/chat_socket_provider.dart';
import 'package:eduprova/features/messages_old/widgets/incoming_call_overlay.dart';
import 'package:eduprova/theme/dark_theme.dart';
import 'package:eduprova/theme/light_theme.dart';
import 'package:eduprova/core/widgets/global_mini_player_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[Main] Start');
  try {
    debugPrint('[Main] Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[Main] Firebase initialized successfully');
  } catch (e) {
    debugPrint('[Main] Firebase initialization failed: $e');
  }

  debugPrint('[Main] Getting SharedPreferences...');
  prefs = await SharedPreferences.getInstance();

  debugPrint('[Main] Initializing MediaKit...');
  MediaKit.ensureInitialized();

  debugPrint('[Main] Initializing PushNotificationService...');
  try {
    await PushNotificationService.instance.initialize();
  } catch (e) {
    debugPrint('[Main] PushNotificationService initialization failed: $e');
  }

  debugPrint('[Main] Running app...');
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authProvider);
    ref.watch(chatSocketProvider.select((state) => state.isConnected));
    final router = ref.watch(routerProvider);
    return _NotificationBootstrapper(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        builder: (context, child) {
          return Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const IncomingCallOverlay(),
              const GlobalMiniPlayerOverlay(),
            ],
          );
        },
        routerConfig: router,
      ),
    );
  }
}

class _AppLifecycleBridge extends ConsumerStatefulWidget {
  final Widget child;

  const _AppLifecycleBridge({required this.child});

  @override
  ConsumerState<_AppLifecycleBridge> createState() =>
      _AppLifecycleBridgeState();
}

class _AppLifecycleBridgeState extends ConsumerState<_AppLifecycleBridge>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(chatSocketProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        notifier.setPresenceStatus(isAway: false);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        notifier.setPresenceStatus(isAway: true);
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _NotificationBootstrapper extends ConsumerStatefulWidget {
  const _NotificationBootstrapper({required this.child});

  final Widget child;

  @override
  ConsumerState<_NotificationBootstrapper> createState() =>
      _NotificationBootstrapperState();
}

class _NotificationBootstrapperState
    extends ConsumerState<_NotificationBootstrapper> {
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription = ref.listenManual<AuthState>(authProvider, (
      previous,
      next,
    ) {
      final isAuthenticated = next.status == AuthStatus.authenticated;
      PushNotificationService.instance.setRef(ref);
      PushNotificationService.instance.syncAuthState(
        isAuthenticated: isAuthenticated,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      PushNotificationService.instance.setRef(ref);
      PushNotificationService.instance.syncAuthState(
        isAuthenticated: authState.status == AuthStatus.authenticated,
      );
    });
  }

  @override
  void dispose() {
    _authSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _AppLifecycleBridge(child: widget.child);
}
