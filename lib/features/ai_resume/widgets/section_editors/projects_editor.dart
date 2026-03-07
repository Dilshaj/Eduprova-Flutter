import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'project_item_editor.dart';

class ProjectsEditor extends ConsumerWidget {
  const ProjectsEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final projects = resume.sections.projects.items;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectItemEditor(),
                ),
              );
            },
          ),
        ],
      ),
      body: projects.isEmpty
          ? _buildEmptyState(context, themeExt)
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(resumeProvider.notifier)
                    .reorderItem('projects', oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = projects[index];
                return Padding(
                  key: ValueKey(item.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProjectCard(context, ref, item, theme, themeExt),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppDesignExtension themeExt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.folder,
            size: 64,
            color: themeExt.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No projects added yet',
            style: TextStyle(color: themeExt.secondaryText, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectItemEditor(),
                ),
              );
            },
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add Project'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    WidgetRef ref,
    ProjectItem item,
    ThemeData theme,
    AppDesignExtension themeExt,
  ) {
    return Card(
      elevation: 0,
      color: themeExt.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: themeExt.borderColor),
      ),
      child: ListTile(
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: item.period.isNotEmpty
            ? Text(item.period, style: const TextStyle(fontSize: 12))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.gripVertical, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 20),
              onPressed: () {
                ref
                    .read(resumeProvider.notifier)
                    .removeItem('projects', item.id);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectItemEditor(item: item),
            ),
          );
        },
      ),
    );
  }
}
