import 'package:flutter/material.dart';
import '../../models/resume_data.dart';
import 'section_items.dart';
import 'shared/color_utils.dart';

class SectionTheme {
  final Color? headingColor;
  final Color? headingBorderColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final bool headingLeft;
  final bool hideHeadingBorder;
  final bool hideHeading;

  const SectionTheme({
    this.headingColor,
    this.headingBorderColor,
    this.iconColor,
    this.textColor,
    this.badgeColor,
    this.badgeTextColor,
    this.headingLeft = false,
    this.hideHeadingBorder = false,
    this.hideHeading = false,
  });
}

class ResumeSection extends StatelessWidget {
  final String sectionId;
  final ResumeData resume;
  final bool isSidebar;
  final SectionTheme? themeOverride;
  final TextStyle? customHeadingStyle;
  final BoxDecoration? headingDecoration;
  final Color? contentColor;
  final CrossAxisAlignment alignment;

  const ResumeSection({
    super.key,
    required this.sectionId,
    required this.resume,
    required this.isSidebar,
    this.themeOverride,
    this.customHeadingStyle,
    this.headingDecoration,
    this.contentColor,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = resume.metadata.design.colors;
    final typography = resume.metadata.typography;

    // Convert hex string to Color
    Color primaryColor = ColorUtils.parseColor(theme.primary, Colors.blue);
    Color textColor =
        themeOverride?.textColor ??
        contentColor ??
        ColorUtils.parseColor(theme.text, Colors.black);

    // Specific theme overrides for title
    Color headingColor = themeOverride?.headingColor ?? primaryColor;
    Color headingBorderColor =
        themeOverride?.headingBorderColor ?? primaryColor;

    // Get section content based on ID
    final sectionData = _getSectionData();
    if (sectionData == null) return const SizedBox.shrink();

    // Check if section is hidden
    bool isHidden = false;
    if (sectionData is Summary) {
      isHidden = sectionData.hidden || sectionData.content.isEmpty;
    }
    if (sectionData is Section) {
      isHidden = sectionData.hidden;
      // Also hide when there are zero visible items
      if (!isHidden) {
        final visibleItems = (sectionData.items as List).where(
          (item) => !item.hidden,
        );
        if (visibleItems.isEmpty) isHidden = true;
      }
    }
    if (isHidden) return const SizedBox.shrink();

    // The heading component
    Widget? headingWidget;
    if (sectionId != 'summary' && themeOverride?.hideHeading != true) {
      headingWidget = Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            width: alignment == CrossAxisAlignment.center
                ? null
                : double.infinity,
            decoration: headingDecoration,
            padding: EdgeInsets.only(
              bottom: themeOverride?.headingLeft == true ? 0 : 2,
            ),
            child: Text(
              _getSectionTitle(sectionData).toUpperCase(),
              style:
                  customHeadingStyle ??
                  TextStyle(
                    fontSize: isSidebar
                        ? typography.heading.fontSize - 2
                        : typography.heading.fontSize - 1,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                    letterSpacing: 1.1,
                  ),
              textAlign: alignment == CrossAxisAlignment.center
                  ? TextAlign.center
                  : TextAlign.start,
            ),
          ),
          if (headingDecoration == null &&
              themeOverride?.hideHeadingBorder != true) ...[
            const SizedBox(height: 4),
            Container(
              height: 1,
              width: double.infinity,
              color: headingBorderColor.withValues(
                alpha: 0.2,
              ), // Adjusted border opacity natively? Need to check if some require solid
            ),
          ],
          if (themeOverride?.headingLeft != true) const SizedBox(height: 10),
        ],
      );
    }

    // Extracted content building
    Widget contentWidget = _buildSectionContent(
      sectionData,
      textColor,
      primaryColor,
      typography.body.fontSize,
    );

    // Left Layout (e.g. Bronzor) vs Standard Column Layout
    if (themeOverride?.headingLeft == true && headingWidget != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: headingWidget),
            const SizedBox(width: 12),
            Expanded(flex: 4, child: contentWidget),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: alignment,
      children: [?headingWidget, contentWidget],
    );
  }

  dynamic _getSectionData() {
    switch (sectionId) {
      case 'summary':
        return resume.summary;
      case 'profiles':
        return resume.sections.profiles;
      case 'experience':
        return resume.sections.experience;
      case 'education':
        return resume.sections.education;
      case 'skills':
        return resume.sections.skills;
      case 'projects':
        return resume.sections.projects;
      case 'languages':
        return resume.sections.languages;
      case 'certifications':
        return resume.sections.certifications;
      case 'awards':
        return resume.sections.awards;
      case 'interests':
        return resume.sections.interests;
      case 'publications':
        return resume.sections.publications;
      case 'volunteer':
        return resume.sections.volunteer;
      case 'references':
        return resume.sections.references;
      default:
        for (final cs in resume.customSections) {
          if (cs.id == sectionId) return cs;
        }
        return null;
    }
  }

  String _getSectionTitle(dynamic sectionData) {
    if (sectionData is Section && sectionData.title.isNotEmpty) {
      return sectionData.title;
    }
    if (sectionData is Summary && sectionData.title.isNotEmpty) {
      return sectionData.title;
    }

    switch (sectionId) {
      case 'basics':
        return 'Basics';
      case 'summary':
        return 'Summary';
      case 'profiles':
        return 'Profiles';
      case 'experience':
        return 'Experience';
      case 'education':
        return 'Education';
      case 'projects':
        return 'Projects';
      case 'skills':
        return 'Skills';
      case 'languages':
        return 'Languages';
      case 'interests':
        return 'Interests';
      case 'awards':
        return 'Awards';
      case 'certifications':
        return 'Certifications';
      case 'publications':
        return 'Publications';
      case 'volunteer':
        return 'Volunteer';
      case 'references':
        return 'References';
      default:
        return sectionId;
    }
  }

  Widget _buildSectionContent(
    dynamic sectionData,
    Color textColor,
    Color primaryColor,
    double bodySize,
  ) {
    if (sectionId == 'summary') {
      return Text(
        (sectionData as Summary).content,
        style: TextStyle(fontSize: bodySize, color: textColor, height: 1.4),
      );
    }

    if (sectionData is Section) {
      final items = sectionData.items as List;
      if (items.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            if (!item.hidden)
              SectionItemRenderer(
                item: item,
                sectionId: sectionId,
                textColor: textColor,
                primaryColor: primaryColor,
                isSidebar: isSidebar,
                metadata: resume.metadata,
                themeOverride: themeOverride,
              ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
