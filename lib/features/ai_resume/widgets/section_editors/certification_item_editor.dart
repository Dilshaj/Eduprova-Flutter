import 'package:eduprova/features/ai_resume/widgets/basic_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class CertificationItemEditor extends ConsumerStatefulWidget {
  final CertificationItem? item;

  const CertificationItemEditor({super.key, this.item});

  @override
  ConsumerState<CertificationItemEditor> createState() =>
      _CertificationItemEditorState();
}

class _CertificationItemEditorState
    extends ConsumerState<CertificationItemEditor> {
  late TextEditingController _titleController;
  late TextEditingController _issuerController;
  late TextEditingController _dateController;
  late TextEditingController _websiteUrlController;
  late TextEditingController _websiteLabelController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _issuerController = TextEditingController(text: widget.item?.issuer ?? '');
    _dateController = TextEditingController(text: widget.item?.date ?? '');
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
    _titleController.dispose();
    _issuerController.dispose();
    _dateController.dispose();
    _websiteUrlController.dispose();
    _websiteLabelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter certification title')),
      );
      return;
    }

    const uuid = Uuid();
    final newItem = CertificationItem(
      id: widget.item?.id ?? uuid.v4(),
      title: title,
      issuer: _issuerController.text.trim(),
      date: _dateController.text.trim(),
      website: Url(
        url: _websiteUrlController.text.trim(),
        label: _websiteLabelController.text.trim(),
      ),
      description: _descriptionController.text.trim(),
      hidden: widget.item?.hidden ?? false,
    );

    if (widget.item == null) {
      ref.read(resumeProvider.notifier).addItem('certifications', newItem);
    } else {
      ref.read(resumeProvider.notifier).updateItem('certifications', newItem);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Add Certification' : 'Edit Certification',
        ),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BasicInput(
              controller: _titleController,
              label: 'Title',
              hint: 'e.g. AWS Certified Solutions Architect',
            ),
            const SizedBox(height: 16),
            BasicInput(
              controller: _issuerController,
              label: 'Issuer',
              hint: 'e.g. Amazon Web Services',
            ),
            const SizedBox(height: 16),
            BasicInput(
              controller: _dateController,
              label: 'Date',
              hint: 'e.g. March 2023',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BasicInput(
                    controller: _websiteLabelController,
                    label: 'Website Label',
                    hint: 'e.g. Credentials',
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
              hint: 'Additional details about the certification...',
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
