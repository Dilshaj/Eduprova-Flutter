import 'package:eduprova/features/ai_resume/widgets/basic_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class ExperienceItemEditor extends ConsumerStatefulWidget {
  final ExperienceItem? item;

  const ExperienceItemEditor({super.key, this.item});

  @override
  ConsumerState<ExperienceItemEditor> createState() =>
      _ExperienceItemEditorState();
}

class _ExperienceItemEditorState extends ConsumerState<ExperienceItemEditor> {
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _locationController;
  late TextEditingController _periodController;
  late TextEditingController _websiteController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(
      text: widget.item?.company ?? '',
    );
    _positionController = TextEditingController(
      text: widget.item?.position ?? '',
    );
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
    _companyController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _periodController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final sections = ref.read(resumeProvider).sections;
    final experience = sections.experience;

    final id =
        widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final newItem = ExperienceItem(
      id: id,
      hidden: widget.item?.hidden ?? false,
      company: _companyController.text,
      position: _positionController.text,
      location: _locationController.text,
      period: _periodController.text,
      website: Url(url: _websiteController.text, label: ''),
      description: _descriptionController.text,
    );

    if (widget.item == null) {
      ref.read(resumeProvider.notifier).addItem('experience', newItem);
    } else {
      final newItems = experience.items
          .map((i) => i.id == id ? newItem : i)
          .toList();
      final newSection = Section<ExperienceItem>(
        title: experience.title,
        columns: experience.columns,
        hidden: experience.hidden,
        items: newItems,
      );
      ref.read(resumeProvider.notifier).updateSection('experience', newSection);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Experience' : 'Edit Experience'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            BasicInput(
              label: 'Company',
              controller: _companyController,
              hint: 'e.g. Google',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Position',
              controller: _positionController,
              hint: 'e.g. Senior Developer',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Period',
              controller: _periodController,
              hint: 'e.g. Jan 2020 - Present',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Location',
              controller: _locationController,
              hint: 'e.g. Mountain View, CA',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Website',
              controller: _websiteController,
              hint: 'https://google.com',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Description',
              controller: _descriptionController,
              hint: 'Describe your roles and responsibilities...',
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }


}
