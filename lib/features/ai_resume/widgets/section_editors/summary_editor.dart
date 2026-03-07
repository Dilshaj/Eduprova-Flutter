import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class SummaryEditor extends ConsumerStatefulWidget {
  const SummaryEditor({super.key});

  @override
  ConsumerState<SummaryEditor> createState() => _SummaryEditorState();
}

class _SummaryEditorState extends ConsumerState<SummaryEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    final summary = ref.read(resumeProvider).summary;
    _titleController = TextEditingController(
      text: summary.title.isEmpty ? 'Summary' : summary.title,
    );
    _contentController = TextEditingController(text: summary.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final summary = ref.read(resumeProvider).summary;
    final newSummary = Summary(
      title: _titleController.text,
      columns: summary.columns,
      hidden: summary.hidden,
      content: _contentController.text,
    );
    ref.read(resumeProvider.notifier).updateSummary(newSummary);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildField(
              'Section Title',
              _titleController,
              'e.g. Summary, About Me',
              theme,
              themeExt,
            ),
            const SizedBox(height: 24),
            _buildField(
              'Content',
              _contentController,
              'Write a brief summary of your professional background...',
              theme,
              themeExt,
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Mocking AI generation
                  setState(() => _contentController.text = "Loading...");
                  await Future.delayed(const Duration(seconds: 1));
                  setState(
                    () => _contentController.text =
                        "A results-driven professional with expertise in building scalable web and mobile applications. Experienced in Dart, Flutter, and Next.js, with a strong focus on clean code and user-centered design.",
                  );
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Generate with AI'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint,
    ThemeData theme,
    AppDesignExtension themeExt, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeExt.secondaryText.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: themeExt.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
