import 'package:eduprova/globals.dart' show prefs;
import 'package:eduprova/routes.dart';
import 'package:eduprova/theme.dart';
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            const GlobalMiniPlayerOverlay(),
          ],
        );
      },
      // theme: ThemeData(
      //   extensions: [],
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color.fromARGB(255, 0, 123, 255),
      //     brightness: .light,
      //   ),
      //   dividerColor: Colors.grey.shade200,
      //   brightness: Brightness.light,
      //   cardColor: const Color(0xFFF9F6FF),
      //   cardTheme: const CardThemeData(color: Color(0xFFF9F6FF)),
      //   scaffoldBackgroundColor: lightBg,
      //   appBarTheme: AppBarThemeData(backgroundColor: lightBg, elevation: 0),
      // ),
      // darkTheme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color.fromARGB(255, 95, 115, 137),
      //     brightness: .dark,
      //   ),
      //   brightness: Brightness.dark,
      //   dividerColor: const Color.fromARGB(255, 39, 38, 46),
      //   cardColor: const Color(0xFF0C0B1E),
      //   cardTheme: const CardThemeData(color: Color(0xFF0C0B1E)),
      //   scaffoldBackgroundColor: darkBg,
      //   outlinedButtonTheme: OutlinedButtonThemeData(
      //     style: OutlinedButton.styleFrom(
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(120),
      //       ),
      //       textStyle: const TextStyle(color: Colors.white),
      //       side: const BorderSide(
      //         color: Color.fromARGB(255, 63, 63, 63),
      //         width: 1,
      //       ),
      //     ),
      //   ),
      //   appBarTheme: AppBarThemeData(backgroundColor: darkBg, elevation: 0),
      // ),
      routerConfig: router,
    );
  }
}
