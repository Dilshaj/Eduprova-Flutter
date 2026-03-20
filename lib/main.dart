import 'package:eduprova/globals.dart' show prefs;
import 'package:eduprova/routes.dart';
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
    final router = ref.watch(routerProvider);
    // final lightBg = Color(0xFFF8F3FA);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            const GlobalMiniPlayerOverlay(),
          ],
        );
      },
      routerConfig: router,
    );
  }
}
