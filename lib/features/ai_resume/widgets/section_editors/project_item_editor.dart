import 'package:eduprova/features/ai_resume/widgets/basic_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class ProjectItemEditor extends ConsumerStatefulWidget {
  final ProjectItem? item;

  const ProjectItemEditor({super.key, this.item});

  @override
  ConsumerState<ProjectItemEditor> createState() => _ProjectItemEditorState();
}

class _ProjectItemEditorState extends ConsumerState<ProjectItemEditor> {
  late TextEditingController _nameController;
  late TextEditingController _periodController;
  late TextEditingController _websiteUrlController;
  late TextEditingController _websiteLabelController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _periodController = TextEditingController(text: widget.item?.period ?? '');
    _websiteUrlController = TextEditingController(
      text: widget.item?.website.url ?? '',
    );
    _websiteLabelController = TextEditingController(
      text: widget.item?.website.label ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _periodController.dispose();
    _websiteUrlController.dispose();
    _websiteLabelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter project name')),
      );
      return;
    }

    const uuid = Uuid();
    final newItem = ProjectItem(
      id: widget.item?.id ?? uuid.v4(),
      name: name,
      period: _periodController.text.trim(),
      website: Url(
        url: _websiteUrlController.text.trim(),
        label: _websiteLabelController.text.trim(),
      ),
      description: _descriptionController.text.trim(),
      hidden: widget.item?.hidden ?? false,
    );

    if (widget.item == null) {
      ref.read(resumeProvider.notifier).addItem('projects', newItem);
    } else {
      ref.read(resumeProvider.notifier).updateItem('projects', newItem);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Project' : 'Edit Project'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BasicInput(
              controller: _nameController,
              label: 'Project Name',
              hint: 'e.g. Edupurva App',
            ),
            const SizedBox(height: 16),
            BasicInput(
              controller: _periodController,
              label: 'Period',
              hint: 'e.g. Jan 2023 - Present',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BasicInput(
                    controller: _websiteLabelController,
                    label: 'Website Label',
                    hint: 'e.g. GitHub',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BasicInput(
                    controller: _websiteUrlController,
                    label: 'Website URL',
                    hint: 'e.g. https://...',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BasicInput(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your project and contributions...',
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
