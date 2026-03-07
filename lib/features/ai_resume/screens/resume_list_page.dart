import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../theme/theme.dart';
import '../providers/resume_list_provider.dart';

class ResumeListPage extends ConsumerStatefulWidget {
  const ResumeListPage({super.key});

  @override
  ConsumerState<ResumeListPage> createState() => _ResumeListPageState();
}

class _ResumeListPageState extends ConsumerState<ResumeListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(resumeListProvider.notifier).loadResumes());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listAsync = ref.watch(resumeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Resumes'), elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(context, ref),
        icon: const Icon(LucideIcons.plus),
        label: const Text('New Resume'),
      ),
      body: listAsync.when(
        data: (resumes) {
          if (resumes.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(resumeListProvider.notifier).loadResumes();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: resumes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final resume = resumes[index];
                return _buildResumeCard(context, ref, resume, theme);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load resumes: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(resumeListProvider.notifier).loadResumes(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileText,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No resumes yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a new resume from scratch\nor import an existing one.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(
    BuildContext context,
    WidgetRef ref,
    resume,
    ThemeData theme,
  ) {
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Dismissible(
      key: ValueKey(resume.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Resume'),
            content: Text('Are you sure you want to delete "${resume.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(resumeListProvider.notifier).deleteResume(resume.id);
      },
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.resumeBuilderEditor(resume.id));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeExt.borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.fileText,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updated ${DateFormat.yMd().add_jm().format(resume.updatedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (resume.isPublic)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Public',
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.chevronRight,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Resume',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(LucideIcons.filePlus2),
                  title: const Text('Start from Scratch'),
                  subtitle: const Text('Create a new blank resume'),
                  onTap: () async {
                    Navigator.pop(context);
                    // Show title input dialog
                    final title = await _showTitleDialog(context);
                    if (title != null && title.isNotEmpty) {
                      final id = await ref
                          .read(resumeListProvider.notifier)
                          .createNewResume(title);
                      if (context.mounted) {
                        context.push(AppRoutes.resumeBuilderEditor(id));
                      }
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(LucideIcons.fileUp),
                  title: const Text('Import Resume'),
                  subtitle: const Text('Upload PDF or DOCX to auto-fill'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.resumeBuilderImport);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showTitleDialog(BuildContext context) {
    final controller = TextEditingController(text: 'Untitled Resume');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resume Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter resume title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
