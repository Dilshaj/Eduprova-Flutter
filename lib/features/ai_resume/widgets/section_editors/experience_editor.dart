import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'experience_item_editor.dart';
import 'section_list_editor.dart';

class ExperienceEditor extends ConsumerWidget {
  const ExperienceEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final experience = ref.watch(resumeProvider).sections.experience;

    return SectionListEditor<ExperienceItem>(
      title: 'Work Experience',
      sectionKey: 'experience',
      items: experience.items,
      idGetter: (item) => item.id,
      emptyStateIcon: LucideIcons.briefcase,
      emptyStateTitle: 'No experience added yet',
      emptyStateSubtitle: 'Add your work history to build your resume',
      emptyStateButtonText: 'Add Experience',
      onAdd: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExperienceItemEditor()),
        );
      },
      onEdit: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExperienceItemEditor(item: item),
          ),
        );
      },
      titleBuilder: (context, item) => Text(
        item.position,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitleBuilder: (context, item) => Column(
        crossAxisAlignment: .start,
        children: [
          const SizedBox(height: 4),
          Text(item.company),
          const SizedBox(height: 2),
          Text(
            item.period,
            style: TextStyle(color: themeExt.secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
