import 'package:edupurva/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 123, 255),
          brightness: .light,
        ),
        dividerColor: Colors.grey.shade200,
        brightness: Brightness.light,
        cardTheme: CardThemeData(color: Color(0xFFF9F6FF)),
        scaffoldBackgroundColor: Color(0xFFF8F3FA),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 123, 255),
          brightness: .dark,
        ),
        brightness: Brightness.dark,
        dividerColor: const Color.fromARGB(255, 39, 38, 46),
        cardTheme: CardThemeData(color: Color(0xFF0C0B1E)),
        scaffoldBackgroundColor: Color(0xFF01070E),
      ),
      routerConfig: router,
    );
  }
}
