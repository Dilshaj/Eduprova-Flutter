import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'project_item_editor.dart';
import 'section_list_editor.dart';

class ProjectsEditor extends ConsumerWidget {
  const ProjectsEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(resumeProvider).sections.projects.items;

    return SectionListEditor<ProjectItem>(
      title: 'Projects',
      sectionKey: 'projects',
      items: projects,
      idGetter: (item) => item.id,
      emptyStateIcon: LucideIcons.folder,
      emptyStateTitle: 'No projects added yet',
      emptyStateButtonText: 'Add Project',
      onAdd: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProjectItemEditor()),
        );
      },
      onEdit: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectItemEditor(item: item),
          ),
        );
      },
      titleBuilder: (context, item) =>
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitleBuilder: (context, item) => item.period.isNotEmpty
          ? Text(item.period, style: const TextStyle(fontSize: 12))
          : null,
    );
  }
}
