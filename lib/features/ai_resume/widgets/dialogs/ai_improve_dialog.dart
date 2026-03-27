import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class AiImproveDialog extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> results;
  const AiImproveDialog({super.key, required this.results});

  @override
  ConsumerState<AiImproveDialog> createState() => _AiImproveDialogState();
}

class _AiImproveDialogState extends ConsumerState<AiImproveDialog> {
  final Map<String, String> _selectedSuggestions = {};

  void _applySelected() {
    final notifier = ref.read(resumeProvider.notifier);
    final resume = ref.read(resumeProvider);
    var updatedResume = resume.copyWith();

    for (final result in widget.results) {
      final id = result['id'] as String;
      final selectedText = _selectedSuggestions[id];
      if (selectedText == null) continue;

      if (id == 'summary') {
        notifier.updateSummary(
          Summary(
            title: updatedResume.summary.title,
            columns: updatedResume.summary.columns,
            hidden: updatedResume.summary.hidden,
            content: selectedText,
          ),
        );
      } else if (id.startsWith('experience_')) {
        final itemId = id.replaceFirst('experience_', '');
        for (final item in updatedResume.sections.experience.items) {
          if (item.id == itemId) {
            notifier.updateItem(
              'experience',
              item.copyWith(description: selectedText),
            );
          }
        }
      } else if (id.startsWith('education_')) {
        final itemId = id.replaceFirst('education_', '');
        for (final item in updatedResume.sections.education.items) {
          if (item.id == itemId) {
            notifier.updateItem(
              'education',
              item.copyWith(description: selectedText),
            );
          }
        }
      } else if (id.startsWith('projects_')) {
        final itemId = id.replaceFirst('projects_', '');
        for (final item in updatedResume.sections.projects.items) {
          if (item.id == itemId) {
            notifier.updateItem(
              'projects',
              item.copyWith(description: selectedText),
            );
          }
        }
      }
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('AI improvements applied!')));
    Navigator.pop(context);
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
        width: isDesktop ? 800 : double.infinity,
        height: isDesktop ? 600 : MediaQuery.sizeOf(context).height * 0.8,
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
          children: [
            Row(
              children: [
                Container(
                  padding: .all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.sparkles,
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
                        'AI Improvements',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Select the suggestions you want to apply.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: widget.results.length,
                separatorBuilder: (context, index) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final result = widget.results[index];
                  final id = result['id'] as String;
                  final title = result['title'] as String;
                  final originalText = result['originalText'] as String;
                  final suggestions = List<String>.from(result['suggestions']);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _OptionCard(
                        title: 'Original',
                        text: originalText,
                        isSelected: _selectedSuggestions[id] == null,
                        onTap: () =>
                            setState(() => _selectedSuggestions.remove(id)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Suggestions',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...suggestions.map((suggestion) {
                        return Padding(
                          padding: .only(bottom: 8),
                          child: _OptionCard(
                            title: 'AI Suggestion',
                            text: stringToTrimmed(suggestion),
                            isSelected:
                                _selectedSuggestions[id] ==
                                stringToTrimmed(suggestion),
                            onTap: () => setState(
                              () => _selectedSuggestions[id] = stringToTrimmed(
                                suggestion,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedSuggestions.isEmpty
                      ? null
                      : _applySelected,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: .symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Selected'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String stringToTrimmed(String s) =>
      s.trim().replaceAll(RegExp(r'^"|"$'), '').trim();
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: .all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.indigo.withValues(alpha: 0.05)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.indigo.withValues(alpha: 0.5)
                : theme.dividerColor.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? LucideIcons.circleCheck : LucideIcons.circle,
                  color: isSelected ? Colors.indigo : theme.hintColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.indigo : theme.hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(text, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
