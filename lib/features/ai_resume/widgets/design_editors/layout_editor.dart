import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class LayoutEditor extends ConsumerWidget {
  const LayoutEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final layout = resume.metadata.layout;

    if (layout.pages.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Layout')),
        body: const Center(child: Text('No layout defined')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Layout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sidebar width slider
          _buildSidebarWidth(ref, resume, theme, themeExt),
          const SizedBox(height: 24),

          // Per-page layouts
          for (var i = 0; i < layout.pages.length; i++) ...[
            _buildPageCard(context, ref, resume, i, theme, themeExt),
            const SizedBox(height: 16),
          ],

          // Add page button
          OutlinedButton.icon(
            onPressed: () => _addPage(ref, resume),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Add Page'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarWidth(
    WidgetRef ref,
    ResumeData resume,
    ThemeData theme,
    AppDesignExtension themeExt,
  ) {
    final layout = resume.metadata.layout;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeExt.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sidebar Width',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                '${layout.sidebarWidth.toInt()}%',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ],
          ),
          Slider(
            value: layout.sidebarWidth,
            min: 20,
            max: 50,
            onChanged: (val) {
              ref
                  .read(resumeProvider.notifier)
                  .updateMetadata(
                    resume.metadata.copyWith(
                      layout: layout.copyWith(sidebarWidth: val),
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(
    BuildContext context,
    WidgetRef ref,
    ResumeData resume,
    int pageIndex,
    ThemeData theme,
    AppDesignExtension themeExt,
  ) {
    final page = resume.metadata.layout.pages[pageIndex];
    final canDelete = resume.metadata.layout.pages.length > 1;

    return Container(
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeExt.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header with fullWidth toggle and delete
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Page ${pageIndex + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),

                // Full Width toggle
                Text(
                  'Full Width',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  height: 24,
                  child: Switch(
                    value: page.fullWidth,
                    onChanged: (val) =>
                        _toggleFullWidth(ref, resume, pageIndex, val),
                  ),
                ),

                if (canDelete) ...[
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => _deletePage(ref, resume, pageIndex),
                    child: const Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main column
                _buildColumn(
                  context,
                  ref,
                  'Main',
                  page.main,
                  pageIndex,
                  true,
                  (item) => _moveSection(
                    ref,
                    resume,
                    pageIndex,
                    item,
                    fromMain: true,
                  ),
                  theme,
                  themeExt,
                  showMoveAction: !page.fullWidth,
                  moveLabel: '→ Sidebar',
                ),

                // Sidebar column (only if not full width)
                if (!page.fullWidth) ...[
                  const SizedBox(height: 12),
                  _buildColumn(
                    context,
                    ref,
                    'Sidebar',
                    page.sidebar,
                    pageIndex,
                    false,
                    (item) => _moveSection(
                      ref,
                      resume,
                      pageIndex,
                      item,
                      fromMain: false,
                    ),
                    theme,
                    themeExt,
                    showMoveAction: true,
                    moveLabel: '→ Main',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<String> items,
    int pageIndex,
    bool isMain,
    void Function(String) onMove,
    ThemeData theme,
    AppDesignExtension themeExt, {
    required bool showMoveAction,
    required String moveLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        DragTarget<Map<String, dynamic>>(
          onWillAcceptWithDetails: (details) {
            final data = details.data;
            return data['item'] != null;
          },
          onAcceptWithDetails: (details) {
            // Dropped onto empty column or end of column
            _handleDrop(
              context,
              ref,
              details.data,
              pageIndex,
              isMain,
              items.length,
            );
          },
          builder: (context, candidateItems, rejectedItems) {
            return Container(
              constraints: const BoxConstraints(minHeight: 60),
              decoration: BoxDecoration(
                color: candidateItems.isNotEmpty
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : themeExt.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: candidateItems.isNotEmpty
                      ? theme.colorScheme.primary
                      : themeExt.borderColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Drag items here',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final key = items[index];
                        return _buildDraggableItem(
                          context,
                          ref,
                          key,
                          index,
                          pageIndex,
                          isMain,
                          onMove,
                          theme,
                          themeExt,
                          showMoveAction,
                          moveLabel,
                        );
                      },
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDraggableItem(
    BuildContext context,
    WidgetRef ref,
    String item,
    int index,
    int pageIndex,
    bool isMain,
    void Function(String) onMove,
    ThemeData theme,
    AppDesignExtension themeExt,
    bool showMoveAction,
    String moveLabel,
  ) {
    final itemData = {
      'item': item,
      'sourcePage': pageIndex,
      'isMain': isMain,
      'sourceIndex': index,
    };

    final child = Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: themeExt.borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        key: ValueKey(item),
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: const Icon(LucideIcons.gripVertical, size: 16),
        title: Text(_sectionLabel(item), style: const TextStyle(fontSize: 13)),
        trailing: showMoveAction
            ? GestureDetector(
                onTap: () => onMove(item),
                child: Text(
                  moveLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            : null,
      ),
    );

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        return data['item'] != null && data['item'] != item;
      },
      onAcceptWithDetails: (details) {
        _handleDrop(
          context, // Safe here since it's just a ref read underneath or we use consumer ref
          ref,
          details.data,
          pageIndex,
          isMain,
          index,
        );
      },
      builder: (context, candidateItems, rejectedItems) {
        return Column(
          children: [
            if (candidateItems.isNotEmpty)
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            LongPressDraggable<Map<String, dynamic>>(
              data: itemData,
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 300,
                  child: Opacity(opacity: 0.8, child: child),
                ),
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: child),
              child: child,
            ),
          ],
        );
      },
    );
  }

  void _handleDrop(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
    int targetPage,
    bool targetIsMain,
    int targetIndex,
  ) {
    final String item = data['item'];
    final int sourcePage = data['sourcePage'];
    final bool sourceIsMain = data['isMain'];
    final int sourceIndex = data['sourceIndex'];

    final resume = ref.read(resumeProvider);
    final pages = List<PageLayout>.from(resume.metadata.layout.pages);

    // 1. Remove from source
    final sourcePageLayout = pages[sourcePage];
    final sourceList = List<String>.from(
      sourceIsMain ? sourcePageLayout.main : sourcePageLayout.sidebar,
    );
    sourceList.removeAt(sourceIndex);
    pages[sourcePage] = sourcePageLayout.copyWith(
      main: sourceIsMain ? sourceList : sourcePageLayout.main,
      sidebar: !sourceIsMain ? sourceList : sourcePageLayout.sidebar,
    );

    // 2. Insert into target
    final targetPageLayout = pages[targetPage];
    final targetList = List<String>.from(
      targetIsMain ? targetPageLayout.main : targetPageLayout.sidebar,
    );

    // Adjust target index if dropping in the same list below the original spot
    int insertIndex = targetIndex;
    if (sourcePage == targetPage &&
        sourceIsMain == targetIsMain &&
        sourceIndex < targetIndex) {
      insertIndex -= 1;
    }
    insertIndex = insertIndex.clamp(0, targetList.length);
    targetList.insert(insertIndex, item);

    pages[targetPage] = targetPageLayout.copyWith(
      main: targetIsMain ? targetList : targetPageLayout.main,
      sidebar: !targetIsMain ? targetList : targetPageLayout.sidebar,
    );

    ref
        .read(resumeProvider.notifier)
        .updateMetadata(
          resume.metadata.copyWith(
            layout: resume.metadata.layout.copyWith(pages: pages),
          ),
        );
  }

  String _sectionLabel(String id) {
    return switch (id) {
      'summary' => 'Summary',
      'experience' => 'Experience',
      'education' => 'Education',
      'skills' => 'Skills',
      'projects' => 'Projects',
      'languages' => 'Languages',
      'certifications' => 'Certifications',
      'awards' => 'Awards',
      'interests' => 'Interests',
      'publications' => 'Publications',
      'volunteer' => 'Volunteer',
      'references' => 'References',
      'profiles' => 'Profiles',
      _ => id,
    };
  }

  // --- Actions ---

  void _updatePageColumn(
    WidgetRef ref,
    ResumeData resume,
    int pageIndex, {
    List<String>? main,
    List<String>? sidebar,
  }) {
    final pages = List<PageLayout>.from(resume.metadata.layout.pages);
    pages[pageIndex] = pages[pageIndex].copyWith(main: main, sidebar: sidebar);
    ref
        .read(resumeProvider.notifier)
        .updateMetadata(
          resume.metadata.copyWith(
            layout: resume.metadata.layout.copyWith(pages: pages),
          ),
        );
  }

  void _moveSection(
    WidgetRef ref,
    ResumeData resume,
    int pageIndex,
    String item, {
    required bool fromMain,
  }) {
    final page = resume.metadata.layout.pages[pageIndex];
    if (fromMain) {
      final newMain = List<String>.from(page.main)..remove(item);
      final newSidebar = List<String>.from(page.sidebar)..add(item);
      _updatePageColumn(
        ref,
        resume,
        pageIndex,
        main: newMain,
        sidebar: newSidebar,
      );
    } else {
      final newSidebar = List<String>.from(page.sidebar)..remove(item);
      final newMain = List<String>.from(page.main)..add(item);
      _updatePageColumn(
        ref,
        resume,
        pageIndex,
        main: newMain,
        sidebar: newSidebar,
      );
    }
  }

  void _toggleFullWidth(
    WidgetRef ref,
    ResumeData resume,
    int pageIndex,
    bool fullWidth,
  ) {
    final pages = List<PageLayout>.from(resume.metadata.layout.pages);
    final page = pages[pageIndex];

    if (fullWidth) {
      // Move all sidebar sections to main
      pages[pageIndex] = page.copyWith(
        fullWidth: true,
        main: [...page.main, ...page.sidebar],
        sidebar: [],
      );
    } else {
      pages[pageIndex] = page.copyWith(fullWidth: false);
    }

    ref
        .read(resumeProvider.notifier)
        .updateMetadata(
          resume.metadata.copyWith(
            layout: resume.metadata.layout.copyWith(pages: pages),
          ),
        );
  }

  void _addPage(WidgetRef ref, ResumeData resume) {
    final newPages = List<PageLayout>.from(resume.metadata.layout.pages)
      ..add(PageLayout(fullWidth: false, main: [], sidebar: []));
    ref
        .read(resumeProvider.notifier)
        .updateMetadata(
          resume.metadata.copyWith(
            layout: resume.metadata.layout.copyWith(pages: newPages),
          ),
        );
  }

  void _deletePage(WidgetRef ref, ResumeData resume, int pageIndex) {
    if (resume.metadata.layout.pages.length <= 1) return;

    final pages = List<PageLayout>.from(resume.metadata.layout.pages);
    final deleted = pages.removeAt(pageIndex);

    // Move sections from deleted page to page 0
    final target = pages[0];
    pages[0] = target.copyWith(
      main: [...target.main, ...deleted.main],
      sidebar: [...target.sidebar, ...deleted.sidebar],
    );

    ref
        .read(resumeProvider.notifier)
        .updateMetadata(
          resume.metadata.copyWith(
            layout: resume.metadata.layout.copyWith(pages: pages),
          ),
        );
  }
}
