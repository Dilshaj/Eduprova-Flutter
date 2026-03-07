import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class TypographyEditor extends ConsumerWidget {
  const TypographyEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Typography')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTypographySection(
            'Body Text',
            resume.metadata.typography.body,
            (newBody) => ref
                .read(resumeProvider.notifier)
                .updateTypography(
                  resume.metadata.typography.copyWith(body: newBody),
                ),
            theme,
            themeExt,
          ),
          const SizedBox(height: 24),
          _buildTypographySection(
            'Headings',
            resume.metadata.typography.heading,
            (newHeading) => ref
                .read(resumeProvider.notifier)
                .updateTypography(
                  resume.metadata.typography.copyWith(heading: newHeading),
                ),
            theme,
            themeExt,
          ),
        ],
      ),
    );
  }

  Widget _buildTypographySection(
    String title,
    TypographyItem item,
    Function(TypographyItem) onChanged,
    ThemeData theme,
    AppDesignExtension themeExt,
  ) {
    final fonts = [
      'Inter',
      'Roboto',
      'Merriweather',
      'IBM Plex Serif',
      'Open Sans',
      'Lato',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeExt.borderColor),
          ),
          child: Column(
            children: [
              _buildDropdownField(
                'Font Family',
                item.fontFamily,
                fonts,
                (val) => onChanged(item.copyWith(fontFamily: val!)),
                theme,
                themeExt,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      'Size',
                      item.fontSize.toString(),
                      (val) {
                        final size = double.tryParse(val);
                        if (size != null) {
                          onChanged(item.copyWith(fontSize: size));
                        }
                      },
                      theme,
                      themeExt,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      'Line Height',
                      item.lineHeight.toString(),
                      (val) {
                        final lh = double.tryParse(val);
                        if (lh != null) {
                          onChanged(item.copyWith(lineHeight: lh));
                        }
                      },
                      theme,
                      themeExt,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    ThemeData theme,
    AppDesignExtension themeExt,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: themeExt.secondaryText),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: themeExt.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String label,
    String value,
    Function(String) onChanged,
    ThemeData theme,
    AppDesignExtension themeExt,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: themeExt.secondaryText),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
          ),
        ),
      ],
    );
  }
}
