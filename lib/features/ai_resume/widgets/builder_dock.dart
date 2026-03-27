import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../providers/resume_provider.dart';
import '../providers/resume_list_provider.dart';
import 'dialogs/ai_tailor_dialog.dart';
import 'dialogs/ai_improve_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BuilderDock extends ConsumerStatefulWidget {
  const BuilderDock({super.key});

  @override
  ConsumerState<BuilderDock> createState() => _BuilderDockState();
}

class _BuilderDockState extends ConsumerState<BuilderDock> {
  bool _isDownloading = false;
  bool _isImproving = false;

  Future<void> _handleDownload() async {
    final resumeNotifier = ref.read(resumeProvider.notifier);
    final resumeId = resumeNotifier.currentResumeId;
    final resume = ref.read(resumeProvider);

    if (resumeId == null || resumeId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Resume ID not found.')));
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final repository = ref.read(resumeRepositoryProvider);
      final response = await repository.downloadResumePdf(resumeId);

      final dir = await getApplicationDocumentsDirectory();
      final name = resume.basics.name.isNotEmpty
          ? resume.basics.name
          : 'resume';
      final filePath = '${dir.path}/$name.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.data!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF downloaded successfully!')),
        );
      }

      await OpenFilex.open(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to download PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _handleImproveWithAI() async {
    setState(() => _isImproving = true);

    try {
      final resume = ref.read(resumeProvider);
      final itemsToImprove = <Map<String, String>>[];
      final itemDataMap = <String, Map<String, String>>{};

      // Summary
      if (resume.summary.content.trim().length > 10) {
        itemsToImprove.add({
          'id': 'summary',
          'text': resume.summary.content.trim(),
        });
        itemDataMap['summary'] = {
          'title': 'Summary',
          'text': resume.summary.content.trim(),
        };
      }

      // Experience
      for (final item in resume.sections.experience.items) {
        if (item.description.trim().length > 10) {
          final id = 'experience_${item.id}';
          itemsToImprove.add({'id': id, 'text': item.description.trim()});
          itemDataMap[id] = {
            'title': 'Experience - ${item.company}',
            'text': item.description.trim(),
          };
        }
      }

      // Education
      for (final item in resume.sections.education.items) {
        if (item.description.trim().length > 10) {
          final id = 'education_${item.id}';
          itemsToImprove.add({'id': id, 'text': item.description.trim()});
          itemDataMap[id] = {
            'title': 'Education - ${item.school}',
            'text': item.description.trim(),
          };
        }
      }

      // Projects
      for (final item in resume.sections.projects.items) {
        if (item.description.trim().length > 10) {
          final id = 'projects_${item.id}';
          itemsToImprove.add({'id': id, 'text': item.description.trim()});
          itemDataMap[id] = {
            'title': 'Project - ${item.name}',
            'text': item.description.trim(),
          };
        }
      }

      if (itemsToImprove.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough text found to improve.')),
        );
        return;
      }

      final repository = ref.read(resumeRepositoryProvider);
      final results = await repository.improveResumeText(itemsToImprove);

      final meaningfulResults = results
          .where(
            (r) =>
                r['suggestions'] != null &&
                (r['suggestions'] as List).isNotEmpty,
          )
          .map((r) {
            final id = r['id'] as String;
            return {
              ...r,
              'title': itemDataMap[id]?['title'] ?? id,
              'originalText': itemDataMap[id]?['text'] ?? '',
            };
          })
          .toList();

      if (meaningfulResults.isNotEmpty && mounted) {
        showDialog(
          context: context,
          builder: (_) => AiImproveDialog(results: meaningfulResults),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI could not find any improvements.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to apply AI improvements.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImproving = false);
    }
  }

  void _showTailorDialog() {
    showDialog(context: context, builder: (_) => const AiTailorDialog());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: .only(bottom: 24),
      padding: .symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DockButton(
            icon: LucideIcons.briefcase,
            label: 'Tailor to Job',
            onTap: _showTailorDialog,
            iconColor: Colors.teal,
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 24,
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 8),
          _DockButton(
            icon: LucideIcons.sparkles,
            label: 'Improve with AI',
            onTap: _isImproving ? null : _handleImproveWithAI,
            iconColor: Colors.indigo,
            isLoading: _isImproving,
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 24,
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 8),
          _DockButton(
            icon: LucideIcons.printer,
            label: 'Download PDF',
            onTap: _isDownloading ? null : _handleDownload,
            isLoading: _isDownloading,
          ),
        ],
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool isLoading;

  const _DockButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: .all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                iconColor?.withValues(alpha: 0.1) ??
                theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          ),
          child: isLoading
              ? SpinKitThreeBounce(
                  color: iconColor ?? theme.iconTheme.color!,
                  size: 16,
                )
              : Icon(icon, size: 20, color: iconColor ?? theme.iconTheme.color),
        ),
      ),
    );
  }
}
