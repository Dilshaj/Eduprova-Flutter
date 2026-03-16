import 'package:eduprova/features/ai_resume/widgets/basic_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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
            BasicInput(
              controller: _nameController,
              label: 'Skill Name',
              hint: 'e.g. React, SQL',
            ),
            const SizedBox(height: 16),
            BasicInput(
              controller: _proficiencyController,
              label: 'Proficiency',
              hint: 'Briefly describe your proficiency',
              maxLines: 3,
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
            BasicInput(
              controller: _keywordsController,
              label: 'Keywords',
              hint: 'e.g. React, JavaScript, Html',
            ),
          ],
        ),
      ),
    );
  }
}
