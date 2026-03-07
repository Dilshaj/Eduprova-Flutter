import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class SkillItemEditor extends ConsumerStatefulWidget {
  final SkillItem? item;

  const SkillItemEditor({super.key, this.item});

  @override
  ConsumerState<SkillItemEditor> createState() => _SkillItemEditorState();
}

class _SkillItemEditorState extends ConsumerState<SkillItemEditor> {
  late TextEditingController _nameController;
  late TextEditingController _proficiencyController;
  late TextEditingController _keywordsController;
  double _level = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _proficiencyController = TextEditingController(
      text: widget.item?.proficiency ?? '',
    );
    _level = (widget.item?.level ?? 0).toDouble();
    _keywordsController = TextEditingController(
      text: widget.item?.keywords.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _proficiencyController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter skill name')));
      return;
    }

    final keywords = _keywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    const uuid = Uuid();
    final newItem = SkillItem(
      id: widget.item?.id ?? uuid.v4(),
      name: name,
      proficiency: _proficiencyController.text.trim(),
      level: _level.toInt(),
      keywords: keywords,
      hidden: widget.item?.hidden ?? false,
      icon: widget.item?.icon ?? '',
    );

    if (widget.item == null) {
      ref.read(resumeProvider.notifier).addItem('skills', newItem);
    } else {
      ref.read(resumeProvider.notifier).updateItem('skills', newItem);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Skill' : 'Edit Skill'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Skill Name',
              hint: 'e.g. Flutter, Project Management',
              themeExt: themeExt,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _proficiencyController,
              label: 'Proficiency',
              hint: 'Briefly describe your proficiency',
              maxLines: 3,
              themeExt: themeExt,
            ),
            const SizedBox(height: 24),
            Text(
              'Skill Level (${_level.toInt()}%)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _level,
              min: 0,
              max: 100,
              divisions: 20,
              label: '${_level.toInt()}%',
              onChanged: (val) {
                setState(() => _level = val);
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _keywordsController,
              label: 'Keywords',
              hint: 'e.g. Dart, Widgets, Riverpod (comma separated)',
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
