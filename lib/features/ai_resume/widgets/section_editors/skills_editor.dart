import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'skill_item_editor.dart';

class SkillsEditor extends ConsumerWidget {
  const SkillsEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final skills = resume.sections.skills.items;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Skills'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkillItemEditor(),
                ),
              );
            },
          ),
        ],
      ),
      body: skills.isEmpty
          ? _buildEmptyState(context, themeExt)
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: skills.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(resumeProvider.notifier)
                    .reorderItem('skills', oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = skills[index];
                return Padding(
                  key: ValueKey(item.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSkillCard(context, ref, item, theme, themeExt),
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
            LucideIcons.wrench,
            size: 64,
            color: themeExt.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No skills added yet',
            style: TextStyle(color: themeExt.secondaryText, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkillItemEditor(),
                ),
              );
            },
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add Skill'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(
    BuildContext context,
    WidgetRef ref,
    SkillItem item,
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
        subtitle: item.proficiency.isNotEmpty
            ? Text(
                item.proficiency,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.level > 0)
              Container(
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
              ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.gripVertical, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 20),
              onPressed: () {
                ref.read(resumeProvider.notifier).removeItem('skills', item.id);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SkillItemEditor(item: item),
            ),
          );
        },
      ),
    );
  }
}
