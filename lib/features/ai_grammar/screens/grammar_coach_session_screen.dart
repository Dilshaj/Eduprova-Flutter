import 'package:flutter/material.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:eduprova/features/ai_grammar/widgets/coach_section.dart';

class GrammarCoachSessionScreen extends StatelessWidget {
  final String? mode;
  final String? topic;

  const GrammarCoachSessionScreen({super.key, this.mode, this.topic});

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeExt.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI Coach',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: CoachSection(
        themeExt: themeExt,
        onBack: () => Navigator.of(context).pop(),
        mode: mode,
        topic: topic,
      ),
    );
  }
}
