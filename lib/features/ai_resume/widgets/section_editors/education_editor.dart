import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'education_item_editor.dart';

class EducationEditor extends ConsumerWidget {
  const EducationEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final education = ref.watch(resumeProvider).sections.education;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Education')),
      body: education.items.isEmpty
          ? _buildEmptyState(context, themeExt)
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: education.items.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(resumeProvider.notifier)
                    .reorderItem('education', oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = education.items[index];
                return Padding(
                  key: ValueKey(item.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEducationCard(context, ref, item, themeExt),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EducationItemEditor(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppDesignExtension themeExt) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(
            LucideIcons.graduationCap,
            size: 64,
            color: themeExt.secondaryText.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No education added yet',
            style: TextStyle(
              color: themeExt.secondaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your academic background to your resume',
            style: TextStyle(
              color: themeExt.secondaryText.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(
    BuildContext context,
    WidgetRef ref,
    EducationItem item,
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
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          item.school,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.gripVertical, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(LucideIcons.pencil, size: 18),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EducationItemEditor(item: item),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                LucideIcons.trash2,
                size: 18,
                color: Colors.pink,
              ),
              onPressed: () {
                ref
                    .read(resumeProvider.notifier)
                    .removeItem('education', item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
