import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../theme/theme.dart';
import 'section_editors/basics_editor.dart';
import 'section_editors/picture_editor.dart';
import 'section_editors/experience_editor.dart';
import 'section_editors/education_editor.dart';
import 'section_editors/summary_editor.dart';
import 'section_editors/skills_editor.dart';
import 'section_editors/projects_editor.dart';
import 'section_editors/certifications_editor.dart';
import 'section_editors/languages_editor.dart';

final sections = [
  _SectionItem(
    title: 'Picture',
    icon: LucideIcons.camera,
    description: 'Profile picture and styling',
    builder: (context) => const PictureEditor(),
  ),
  _SectionItem(
    title: 'Personal Details',
    icon: LucideIcons.user,
    description: 'Name, email, phone, location',
    builder: (context) => const BasicsEditor(),
  ),
  _SectionItem(
    title: 'Summary',
    icon: LucideIcons.fileText,
    description: 'Professional summary or bio',
    builder: (context) => const SummaryEditor(),
  ),
  _SectionItem(
    title: 'Experience',
    icon: LucideIcons.briefcase,
    description: 'Work history and professional experience',
    builder: (context) => const ExperienceEditor(),
  ),
  _SectionItem(
    title: 'Education',
    icon: LucideIcons.graduationCap,
    description: 'Educational background and degrees',
    builder: (context) => const EducationEditor(),
  ),
  _SectionItem(
    title: 'Skills',
    icon: LucideIcons.wrench,
    description: 'Technical and soft skills',
    builder: (context) => const SkillsEditor(),
  ),
  _SectionItem(
    title: 'Projects',
    icon: LucideIcons.folder,
    description: 'Personal or professional projects',
    builder: (context) => const ProjectsEditor(),
  ),
  _SectionItem(
    title: 'Certifications',
    icon: LucideIcons.award,
    description: 'Courses and certifications',
    builder: (context) => const CertificationsEditor(),
  ),
  _SectionItem(
    title: 'Languages',
    icon: LucideIcons.languages,
    description: 'Languages you speak',
    builder: (context) => const LanguagesEditor(),
  ),
];

class SectionListView extends ConsumerWidget {
  const SectionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final section = sections[index];
        return Card(
          elevation: 0,
          color: themeExt.cardColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: themeExt.borderColor),
          ),
          child: ListTile(
            // radius
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                // color: themeExt.cardColor,
                // color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(section.icon, color: theme.colorScheme.primary),
            ),
            title: Text(
              section.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              section.description,
              style: TextStyle(color: themeExt.secondaryText, fontSize: 13),
            ),
            trailing: const Icon(Icons.chevron_right),
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

class _SectionItem {
  final String title;
  final IconData icon;
  final String description;
  final WidgetBuilder builder;

  _SectionItem({
    required this.title,
    required this.icon,
    required this.description,
    required this.builder,
  });
}
