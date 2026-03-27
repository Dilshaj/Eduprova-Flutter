import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'language_item_editor.dart';
import 'section_list_editor.dart';

class LanguagesEditor extends ConsumerWidget {
  const LanguagesEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final languages = ref.watch(resumeProvider).sections.languages.items;

    return SectionListEditor<LanguageItem>(
      title: 'Languages',
      sectionKey: 'languages',
      items: languages,
      idGetter: (item) => item.id,
      emptyStateIcon: LucideIcons.languages,
      emptyStateTitle: 'No languages added yet',
      emptyStateButtonText: 'Add Language',
      onAdd: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LanguageItemEditor()),
        );
      },
      onEdit: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LanguageItemEditor(item: item),
          ),
        );
      },
      titleBuilder: (context, item) => Text(
        item.language,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitleBuilder: (context, item) => item.fluency.isNotEmpty
          ? Text(item.fluency, style: const TextStyle(fontSize: 12))
          : null,
      trailingBuilder: (context, item) => item.level > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Level ${item.level}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
