import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'education_item_editor.dart';
import 'section_list_editor.dart';

class EducationEditor extends ConsumerWidget {
  const EducationEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final education = ref.watch(resumeProvider).sections.education;

    return SectionListEditor<EducationItem>(
      title: 'Education',
      sectionKey: 'education',
      items: education.items,
      idGetter: (item) => item.id,
      emptyStateIcon: LucideIcons.graduationCap,
      emptyStateTitle: 'No education added yet',
      emptyStateSubtitle: 'Add your academic background to your resume',
      emptyStateButtonText: 'Add Education',
      onAdd: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EducationItemEditor()),
        );
      },
      onEdit: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EducationItemEditor(item: item),
          ),
        );
      },
      titleBuilder: (context, item) => Text(
        item.school,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitleBuilder: (context, item) => Column(
        crossAxisAlignment: .start,
        children: [
          const SizedBox(height: 4),
          Text('${item.degree} in ${item.area}'),
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
