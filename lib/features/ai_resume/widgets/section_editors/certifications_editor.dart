import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'certification_item_editor.dart';

class CertificationsEditor extends ConsumerWidget {
  const CertificationsEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final certifications = resume.sections.certifications.items;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Certifications'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CertificationItemEditor(),
                ),
              );
            },
          ),
        ],
      ),
      body: certifications.isEmpty
          ? _buildEmptyState(context, themeExt)
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: certifications.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(resumeProvider.notifier)
                    .reorderItem('certifications', oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = certifications[index];
                return Padding(
                  key: ValueKey(item.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCertificationCard(
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
            LucideIcons.award,
            size: 64,
            color: themeExt.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No certifications added yet',
            style: TextStyle(color: themeExt.secondaryText, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CertificationItemEditor(),
                ),
              );
            },
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add Certification'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationCard(
    BuildContext context,
    WidgetRef ref,
    CertificationItem item,
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
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.issuer.isNotEmpty)
              Text(item.issuer, style: const TextStyle(fontSize: 12)),
            if (item.date.isNotEmpty)
              Text(item.date, style: const TextStyle(fontSize: 12)),
          ],
        ),
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
                    .removeItem('certifications', item.id);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CertificationItemEditor(item: item),
            ),
          );
        },
      ),
    );
  }
}
