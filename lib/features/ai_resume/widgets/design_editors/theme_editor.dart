import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../theme/theme.dart';
import '../../providers/resume_provider.dart';

class ThemeEditor extends ConsumerWidget {
  const ThemeEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final resumeTheme = resume.metadata.design.colors;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildColorSection(
            'Primary Color',
            resumeTheme.primary,
            (color) => ref
                .read(resumeProvider.notifier)
                .updateTheme(resumeTheme.copyWith(primary: color)),
            theme,
            themeExt,
          ),
          const SizedBox(height: 24),
          _buildColorSection(
            'Text Color',
            resumeTheme.text,
            (color) => ref
                .read(resumeProvider.notifier)
                .updateTheme(resumeTheme.copyWith(text: color)),
            theme,
            themeExt,
          ),
          const SizedBox(height: 24),
          _buildColorSection(
            'Background Color',
            resumeTheme.background,
            (color) => ref
                .read(resumeProvider.notifier)
                .updateTheme(resumeTheme.copyWith(background: color)),
            theme,
            themeExt,
          ),
          const SizedBox(height: 24),
          _buildSkillStyleSection(
            resume.metadata.design.level.type,
            (style) =>
                ref.read(resumeProvider.notifier).updateSkillLevelStyle(style),
            theme,
            themeExt,
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(
    String title,
    String hexColor,
    Function(String) onChanged,
    ThemeData theme,
    AppDesignExtension themeExt,
  ) {
    final presetColors = [
      '#3b82f6', // blue
      '#6366f1', // indigo
      '#14b8a6', // teal
      '#10b981', // green
      '#f59e0b', // orange
      '#ef4444', // red
      '#a855f7', // purple
      '#000000', // black
      '#ffffff', // white
    ];

    final currentColor = _hexToColor(hexColor);

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
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: presetColors.map((hex) {
                  final isSelected =
                      hex.toLowerCase() == hexColor.toLowerCase();
                  final color = _hexToColor(hex);
                  return GestureDetector(
                    onTap: () => onChanged(hex),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : themeExt.borderColor,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 20,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: hexColor,
                      decoration: InputDecoration(
                        labelText: 'Hex Color',
                        hintText: '#RRGGBB',
                        prefixIcon: const Icon(LucideIcons.hash, size: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onFieldSubmitted: (val) {
                        if (val.startsWith('#') &&
                            (val.length == 7 || val.length == 9)) {
                          onChanged(val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: themeExt.borderColor),
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

  Widget _buildSkillStyleSection(
    String currentStyle,
    Function(String) onChanged,
    ThemeData theme,
    AppDesignExtension themeExt,
  ) {
    final styles = [
      ('Bar', 'bar', LucideIcons.minus),
      ('Dots', 'dots', LucideIcons.ellipsis),
      ('Text', 'text', LucideIcons.type),
      ('Circle', 'circle', LucideIcons.circle),
      ('Square', 'square', LucideIcons.square),
      ('Rectangle', 'rectangle', LucideIcons.rectangleHorizontal),
      ('Full Width', 'full-width', LucideIcons.stretchHorizontal),
      ('Progress', 'progress', LucideIcons.loader),
      ('Icon', 'icon', LucideIcons.star),
      ('Hide', 'hide', LucideIcons.eyeOff),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Skill Level Style',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeExt.borderColor),
          ),
          child: Column(
            children: styles.map((style) {
              final isSelected = currentStyle == style.$2;
              return ListTile(
                onTap: () => onChanged(style.$2),
                leading: Icon(style.$3, size: 20),
                title: Text(style.$1),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : null,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    if (h.length == 8) return Color(int.parse(h, radix: 16));
    return Colors.transparent;
  }
}
