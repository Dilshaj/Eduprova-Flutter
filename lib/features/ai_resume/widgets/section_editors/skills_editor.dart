import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'skill_item_editor.dart';
import 'section_list_editor.dart';

class SkillsEditor extends ConsumerWidget {
  const SkillsEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final skills = ref.watch(resumeProvider).sections.skills.items;

    return SectionListEditor<SkillItem>(
      title: 'Skills',
      sectionKey: 'skills',
      items: skills,
      idGetter: (item) => item.id,
      emptyStateIcon: LucideIcons.wrench,
      emptyStateTitle: 'No skills added yet',
      emptyStateButtonText: 'Add Skill',
      onAdd: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SkillItemEditor()),
        );
      },
      onEdit: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SkillItemEditor(item: item)),
        );
      },
      titleBuilder: (context, item) =>
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitleBuilder: (context, item) => item.proficiency.isNotEmpty
          ? Text(item.proficiency, maxLines: 1, overflow: TextOverflow.ellipsis)
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
