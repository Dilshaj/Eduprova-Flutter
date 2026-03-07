import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme.dart';
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
    final themeExt = theme.extension<AppDesignExtension>()!;

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
            _buildField(
              'Company',
              _companyController,
              'e.g. Google',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Position',
              _positionController,
              'e.g. Senior Developer',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Period',
              _periodController,
              'e.g. Jan 2020 - Present',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Location',
              _locationController,
              'e.g. Mountain View, CA',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Website',
              _websiteController,
              'https://google.com',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Description',
              _descriptionController,
              'Describe your roles and responsibilities...',
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
