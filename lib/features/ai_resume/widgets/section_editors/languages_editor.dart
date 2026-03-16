import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'language_item_editor.dart';

class LanguagesEditor extends ConsumerWidget {
  const LanguagesEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final languages = resume.sections.languages.items;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Languages'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageItemEditor(),
                ),
              );
            },
          ),
        ],
      ),
      body: languages.isEmpty
          ? _buildEmptyState(context, themeExt)
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: languages.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(resumeProvider.notifier)
                    .reorderItem('languages', oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = languages[index];
                return Padding(
                  key: ValueKey(item.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLanguageCard(
                    context,
                    ref,
                    item,
                    theme,
                    themeExt,
                  ),
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
            LucideIcons.languages,
            size: 64,
            color: themeExt.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No languages added yet',
            style: TextStyle(color: themeExt.secondaryText, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageItemEditor(),
                ),
              );
            },
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add Language'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    WidgetRef ref,
    LanguageItem item,
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
          item.language,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: item.fluency.isNotEmpty
            ? Text(item.fluency, style: const TextStyle(fontSize: 12))
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
                ref
                    .read(resumeProvider.notifier)
                    .removeItem('languages', item.id);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LanguageItemEditor(item: item),
            ),
          );
        },
      ),
    );
  }
}
