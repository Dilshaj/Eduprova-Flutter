import 'package:eduprova/features/ai_resume/widgets/basic_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class EducationItemEditor extends ConsumerStatefulWidget {
  final EducationItem? item;

  const EducationItemEditor({super.key, this.item});

  @override
  ConsumerState<EducationItemEditor> createState() =>
      _EducationItemEditorState();
}

class _EducationItemEditorState extends ConsumerState<EducationItemEditor> {
  late TextEditingController _schoolController;
  late TextEditingController _degreeController;
  late TextEditingController _areaController;
  late TextEditingController _gradeController;
  late TextEditingController _locationController;
  late TextEditingController _periodController;
  late TextEditingController _websiteController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _schoolController = TextEditingController(text: widget.item?.school ?? '');
    _degreeController = TextEditingController(text: widget.item?.degree ?? '');
    _areaController = TextEditingController(text: widget.item?.area ?? '');
    _gradeController = TextEditingController(text: widget.item?.grade ?? '');
    _locationController = TextEditingController(
      text: widget.item?.location ?? '',
    );
    _periodController = TextEditingController(text: widget.item?.period ?? '');
    _websiteController = TextEditingController(
      text: widget.item?.website.url ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _degreeController.dispose();
    _areaController.dispose();
    _gradeController.dispose();
    _locationController.dispose();
    _periodController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final sections = ref.read(resumeProvider).sections;
    final education = sections.education;

    final id =
        widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final newItem = EducationItem(
      id: id,
      hidden: widget.item?.hidden ?? false,
      school: _schoolController.text,
      degree: _degreeController.text,
      area: _areaController.text,
      grade: _gradeController.text,
      location: _locationController.text,
      period: _periodController.text,
      website: Url(url: _websiteController.text, label: ''),
      description: _descriptionController.text,
    );

    if (widget.item == null) {
      ref.read(resumeProvider.notifier).addItem('education', newItem);
    } else {
      final newItems = education.items
          .map((i) => i.id == id ? newItem : i)
          .toList();
      final newSection = Section<EducationItem>(
        title: education.title,
        columns: education.columns,
        hidden: education.hidden,
        items: newItems,
      );
      ref.read(resumeProvider.notifier).updateSection('education', newSection);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Education' : 'Edit Education'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            BasicInput(
              label: 'School / University',
              controller: _schoolController,
              hint: 'e.g. Stanford University',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Degree',
              controller: _degreeController,
              hint: 'e.g. Master of Science',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Area of Study',
              controller: _areaController,
              hint: 'e.g. Computer Science',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BasicInput(
                    label: 'Grade (GPA)',
                    controller: _gradeController,
                    hint: 'e.g. 3.8/4.0',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BasicInput(
                    label: 'Period',
                    controller: _periodController,
                    hint: 'e.g. 2018 - 2022',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Location',
              controller: _locationController,
              hint: 'e.g. California, USA',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Website',
              controller: _websiteController,
              hint: 'https://stanford.edu',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Description',
              controller: _descriptionController,
              hint: 'Describe your studies, honors, etc...',
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
