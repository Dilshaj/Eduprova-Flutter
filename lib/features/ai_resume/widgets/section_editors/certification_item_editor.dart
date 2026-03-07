import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../theme.dart';
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
            _buildTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'e.g. AWS Certified Solutions Architect',
              themeExt: themeExt,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _issuerController,
              label: 'Issuer',
              hint: 'e.g. Amazon Web Services',
              themeExt: themeExt,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _dateController,
              label: 'Date',
              hint: 'e.g. March 2023',
              themeExt: themeExt,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _websiteLabelController,
                    label: 'Website Label',
                    hint: 'e.g. Credentials',
                    themeExt: themeExt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _websiteUrlController,
                    label: 'Website URL',
                    hint: 'e.g. https://...',
                    themeExt: themeExt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Additional details about the certification...',
              maxLines: 5,
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
