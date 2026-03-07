import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme.dart';
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
    final themeExt = theme.extension<AppDesignExtension>()!;

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
            _buildField(
              'School / University',
              _schoolController,
              'e.g. Stanford University',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Degree',
              _degreeController,
              'e.g. Master of Science',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Area of Study',
              _areaController,
              'e.g. Computer Science',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    'Grade (GPA)',
                    _gradeController,
                    'e.g. 3.8/4.0',
                    theme,
                    themeExt,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    'Period',
                    _periodController,
                    'e.g. 2018 - 2022',
                    theme,
                    themeExt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(
              'Location',
              _locationController,
              'e.g. California, USA',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Website',
              _websiteController,
              'https://stanford.edu',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Description',
              _descriptionController,
              'Describe your studies, honors, etc...',
              theme,
              themeExt,
              maxLines: 5,
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
