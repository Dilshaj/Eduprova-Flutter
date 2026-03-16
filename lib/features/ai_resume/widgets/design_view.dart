import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/theme.dart';
import 'design_editors/template_editor.dart';
import 'design_editors/layout_editor.dart';
import 'design_editors/typography_editor.dart';
import 'design_editors/theme_editor.dart';

class DesignView extends ConsumerWidget {
  const DesignView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    final sections = [
      _DesignSection(
        title: 'Templates',
        subtitle: 'Choose your resume design',
        icon: LucideIcons.layout,
        builder: (context) => const TemplateEditor(),
      ),
      _DesignSection(
        title: 'Layout',
        subtitle: 'Reorder sections and columns',
        icon: LucideIcons.columns,
        builder: (context) => const LayoutEditor(),
      ),
      _DesignSection(
        title: 'Typography',
        subtitle: 'Fonts and text sizes',
        icon: LucideIcons.type,
        builder: (context) => const TypographyEditor(),
      ),
      _DesignSection(
        title: 'Theme',
        subtitle: 'Colors and appearance',
        icon: LucideIcons.palette,
        builder: (context) => const ThemeEditor(),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final section = sections[index];
        return Card(
          elevation: 0,
          color: themeExt.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: themeExt.borderColor),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                section.icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            title: Text(
              section.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              section.subtitle,
              style: TextStyle(color: themeExt.secondaryText, fontSize: 13),
            ),
            trailing: const Icon(LucideIcons.chevronRight, size: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: section.builder),
              );
            },
          ),
        );
      },
    );
  }
}

class _DesignSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;

  _DesignSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}
