import 'package:flutter/material.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:eduprova/features/ai_grammar/widgets/active_roleplay_session.dart';

class GrammarRoleplaySessionScreen extends StatelessWidget {
  final String title;
  final String difficulty;
  final String roleType;
  final Map<String, dynamic>? config;

  const GrammarRoleplaySessionScreen({
    super.key,
    required this.title,
    required this.difficulty,
    required this.roleType,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: SafeArea(
        child: ActiveRoleplaySession(
          title: title,
          difficulty: difficulty,
          roleType: roleType,
          themeExt: themeExt,
          config: config,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
