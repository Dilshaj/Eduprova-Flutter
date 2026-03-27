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
  prefs = await SharedPreferences.getInstance();
  MediaKit.ensureInitialized();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authProvider);
    ref.watch(chatSocketProvider.select((state) => state.isConnected));
    final router = ref.watch(routerProvider);
    return _AppLifecycleBridge(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: Stack(
              children: [
                child ?? const SizedBox.shrink(),
                const IncomingCallOverlay(key: ValueKey('incoming_call_overlay')),
                const GlobalMiniPlayerOverlay(key: ValueKey('global_mini_player_overlay')),
              ],
            ),
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
  ConsumerState<_AppLifecycleBridge> createState() => _AppLifecycleBridgeState();
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
