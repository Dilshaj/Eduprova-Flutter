import 'package:eduprova/features/ai_resume/widgets/basic_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class LanguageItemEditor extends ConsumerStatefulWidget {
  final LanguageItem? item;

  const LanguageItemEditor({super.key, this.item});

  @override
  ConsumerState<LanguageItemEditor> createState() => _LanguageItemEditorState();
}

class _LanguageItemEditorState extends ConsumerState<LanguageItemEditor> {
  late TextEditingController _languageController;
  late TextEditingController _fluencyController;
  late TextEditingController _levelController;

  @override
  void initState() {
    super.initState();
    _languageController = TextEditingController(
      text: widget.item?.language ?? '',
    );
    _fluencyController = TextEditingController(
      text: widget.item?.fluency ?? '',
    );
    _levelController = TextEditingController(
      text: widget.item?.level.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _languageController.dispose();
    _fluencyController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _save() {
    final language = _languageController.text.trim();
    if (language.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter language')));
      return;
    }

    const uuid = Uuid();
    final newItem = LanguageItem(
      id: widget.item?.id ?? uuid.v4(),
      language: language,
      fluency: _fluencyController.text.trim(),
      level: int.tryParse(_levelController.text.trim()) ?? 0,
      hidden: widget.item?.hidden ?? false,
    );

    if (widget.item == null) {
      ref.read(resumeProvider.notifier).addItem('languages', newItem);
    } else {
      ref.read(resumeProvider.notifier).updateItem('languages', newItem);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Language' : 'Edit Language'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BasicInput(
              controller: _languageController,
              label: 'Language',
              hint: 'e.g. English, Spanish',
            ),
            const SizedBox(height: 16),
            BasicInput(
              controller: _fluencyController,
              label: 'Fluency',
              hint: 'e.g. Native, Fluent, Basic',
            ),
            const SizedBox(height: 16),
            BasicInput(
              controller: _levelController,
              label: 'Level (0-5)',
              hint: 'e.g. 5 for Native',
              keyboardType: .number,
            ),
          ],
        ),
      ),
    );
  }
}
