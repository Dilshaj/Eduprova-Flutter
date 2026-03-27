import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';

class SectionListEditor<T> extends ConsumerWidget {
  final String title;
  final String sectionKey;
  final List<T> items;
  final String Function(T) idGetter;
  final Widget Function(BuildContext context, T item) titleBuilder;
  final Widget? Function(BuildContext context, T item)? subtitleBuilder;
  final Widget? Function(BuildContext context, T item)? trailingBuilder;
  final void Function(T item) onEdit;
  final VoidCallback onAdd;
  final IconData emptyStateIcon;
  final String emptyStateTitle;
  final String? emptyStateSubtitle;
  final String emptyStateButtonText;

  const SectionListEditor({
    super.key,
    required this.title,
    required this.sectionKey,
    required this.items,
    required this.idGetter,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.trailingBuilder,
    required this.onEdit,
    required this.onAdd,
    required this.emptyStateIcon,
    required this.emptyStateTitle,
    this.emptyStateSubtitle,
    required this.emptyStateButtonText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(icon: const Icon(LucideIcons.plus), onPressed: onAdd),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyState(context, themeExt)
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(resumeProvider.notifier)
                    .reorderItem(sectionKey, oldIndex, newIndex);
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final animValue = Curves.easeInOut.transform(
                      animation.value,
                    );
                    final elevation = 3.0 + (animValue * 5.0);
                    return Material(
                      elevation: elevation,
                      color: Colors.transparent,
                      shadowColor: isDark
                          ? Colors.black
                          : Colors.black.withValues(alpha: 0.2),
                      child: child,
                    );
                  },
                );
              },
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  key: ValueKey(idGetter(item)),
                  color: themeExt.cardColor.withValues(alpha: 1),
                  margin: .only(bottom: 12),
                  clipBehavior: Clip.hardEdge,
                  // shadow
                  shadowColor: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.2),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: .circular(12),
                    side: BorderSide(color: themeExt.borderColor),
                  ),
                  child: ListTile(
                    contentPadding: .symmetric(horizontal: 16, vertical: 8),
                    onTap: () => onEdit(item),
                    title: titleBuilder(context, item),
                    subtitle: subtitleBuilder != null
                        ? subtitleBuilder!(context, item)
                        : null,
                    trailing: Row(
                      mainAxisSize: .min,
                      children: [
                        ?trailingBuilder?.call(context, item),
                        IconButton(
                          icon: Icon(
                            LucideIcons.trash2,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () {
                            ref
                                .read(resumeProvider.notifier)
                                .removeItem(sectionKey, idGetter(item));
                          },
                        ),
                        const SizedBox(width: 8),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(
                            LucideIcons.gripVertical,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppDesignExtension themeExt) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(
            emptyStateIcon,
            size: 64,
            color: themeExt.secondaryText.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            emptyStateTitle,
            style: TextStyle(
              color: themeExt.secondaryText,
              fontSize: 16,
              fontWeight: emptyStateSubtitle != null ? .w500 : .normal,
            ),
          ),
          if (emptyStateSubtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              emptyStateSubtitle!,
              style: TextStyle(
                color: themeExt.secondaryText.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(LucideIcons.plus),
            label: Text(emptyStateButtonText),
          ),
        ],
      ),
    );
  }
}
