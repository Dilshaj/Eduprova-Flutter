import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../theme.dart';
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
            _buildTextField(
              controller: _languageController,
              label: 'Language',
              hint: 'e.g. English, Spanish',
              themeExt: themeExt,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _fluencyController,
              label: 'Fluency',
              hint: 'e.g. Native, Fluent, Basic',
              themeExt: themeExt,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _levelController,
              label: 'Level (0-5)',
              hint: 'e.g. 5 for Native',
              keyboardType: .number,
              themeExt: themeExt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required AppDesignExtension themeExt,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
          decoration: .new(
            hintText: hint,
            filled: true,
            fillColor: themeExt.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
