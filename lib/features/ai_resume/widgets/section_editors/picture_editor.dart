import 'package:eduprova/features/ai_resume/widgets/basic_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class PictureEditor extends ConsumerStatefulWidget {
  const PictureEditor({super.key});

  @override
  ConsumerState<PictureEditor> createState() => _PictureEditorState();
}

class _PictureEditorState extends ConsumerState<PictureEditor> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final picture = ref.read(resumeProvider).picture;
    _urlController = TextEditingController(text: picture.url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _urlController.text = image.path;
      _update(ref.read(resumeProvider).picture.copyWith(url: image.path));
    }
  }

  void _update(Picture newPicture) {
    ref.read(resumeProvider.notifier).updatePicture(newPicture);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final picture = ref.watch(resumeProvider).picture;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Profile Picture')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildPreview(picture, themeExt, theme),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(LucideIcons.upload, size: 18),
                label: const Text('Pick from Gallery'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSwitch(
              'Show Picture',
              !picture.hidden,
              (val) => _update(picture.copyWith(hidden: !val)),
              themeExt,
            ),
            const SizedBox(height: 24),
            BasicInput(
              controller: _urlController,
              label: 'Picture URL',
              hint: 'https://example.com/photo.jpg',
              // onChanged: (val) => _update(picture.copyWith(url: val)),
              // themeExt: themeExt,
            ),
            const SizedBox(height: 32),
            Text(
              'Style Settings',
              style: TextStyle(
                fontWeight: .bold,
                fontSize: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSlider(
              'Size',
              picture.size,
              40,
              150,
              (val) => _update(picture.copyWith(size: val)),
              themeExt,
            ),
            _buildSlider(
              'Border Radius',
              picture.borderRadius,
              0,
              75,
              (val) => _update(picture.copyWith(borderRadius: val)),
              themeExt,
            ),
            _buildSlider(
              'Rotation',
              picture.rotation,
              -180,
              180,
              (val) => _update(picture.copyWith(rotation: val)),
              themeExt,
            ),
            const SizedBox(height: 24),
            Text(
              'Aspect Ratio',
              style: const TextStyle(fontWeight: .bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildAspectRatioButtons(picture, themeExt, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(
    Picture picture,
    AppDesignExtension themeExt,
    ThemeData theme,
  ) {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: themeExt.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeExt.borderColor),
        ),
        child: Center(
          child: Transform.rotate(
            angle: picture.rotation * (3.14159 / 180),
            child: Container(
              width: picture.size,
              height: picture.size / picture.aspectRatio,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(picture.borderRadius),
                border: Border.all(color: theme.colorScheme.primary, width: 2),
                image: picture.url.isNotEmpty
                    ? DecorationImage(
                        image: picture.url.startsWith('http')
                            ? NetworkImage(picture.url)
                            : FileImage(File(picture.url)) as ImageProvider,
                        fit: .cover,
                      )
                    : null,
              ),
              child: picture.url.isEmpty
                  ? Icon(
                      LucideIcons.user,
                      size: picture.size * 0.5,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    AppDesignExtension themeExt,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeExt.borderColor),
      ),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontWeight: .bold)),
        value: value,
        onChanged: onChanged,
        contentPadding: .zero,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    required AppDesignExtension themeExt,
  }) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, style: const TextStyle(fontWeight: .bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
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

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    AppDesignExtension themeExt,
  ) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: .w600, fontSize: 13),
            ),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(color: themeExt.secondaryText, fontSize: 12),
            ),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _buildAspectRatioButtons(
    Picture picture,
    AppDesignExtension themeExt,
    ThemeData theme,
  ) {
    final ratios = {
      'Square': 1.0,
      'Video': 16 / 9,
      'Cinema': 21 / 9,
      'Portait': 3 / 4,
    };

    return Wrap(
      spacing: 8,
      children: [
        for (var entry in ratios.entries)
          ChoiceChip(
            label: Text(entry.key),
            selected: (picture.aspectRatio - entry.value).abs() < 0.01,
            onSelected: (val) {
              if (val) _update(picture.copyWith(aspectRatio: entry.value));
            },
          ),
      ],
    );
  }
}
