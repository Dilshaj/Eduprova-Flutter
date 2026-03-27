import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/resume_provider.dart';
import '../../providers/resume_list_provider.dart';
import '../../models/resume_data.dart';

class AiTailorDialog extends ConsumerStatefulWidget {
  const AiTailorDialog({super.key});

  @override
  ConsumerState<AiTailorDialog> createState() => _AiTailorDialogState();
}

class _AiTailorDialogState extends ConsumerState<AiTailorDialog> {
  final _controller = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTailor() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Job Description.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final repository = ref.read(resumeRepositoryProvider);
      final resume = ref.read(resumeProvider);

      final response = await repository.tailorResume(
        resume,
        _controller.text.trim(),
      );

      if (response['updatedResume'] != null) {
        final updatedData = ResumeData.fromJson(response['updatedResume']);
        // Use individual update methods or replace the entire state
        // The easiest way is to push it as a whole if the provider supported it.
        // We'll update properties one by one or create a specific method in the provider.
        final notifier = ref.read(resumeProvider.notifier);
        notifier.updateSummary(updatedData.summary);

        // Update sections
        updatedData.sections.toJson().forEach((key, value) {
          // updateSection needs a section object, we can reconstruct or handle it simply.
          notifier.updateSection(
            key,
            updatedData.sections.toJson()[key] as dynamic,
          ); // this might need a helper, let's look at `updateSection`
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume successfully tailored!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('No updated resume returned.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to tailor resume. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width > 768;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      insetPadding: .all(8),
      backgroundColor: Colors.transparent,
      child: Container(
        width: isDesktop ? 600 : double.infinity,
        padding: .all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: .all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.briefcase,
                    color: Colors.indigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tailor Resume to Job',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Paste the Job Description below to let AI rewrite your resume.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 8,
              minLines: 5,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                hintText: 'Paste Job Description here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _handleTailor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: .symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                      : const Text('Tailor Resume'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
