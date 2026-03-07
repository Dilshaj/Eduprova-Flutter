import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';
import '../shared/template_header.dart';

/// Onyx: NO sidebar, header left-aligned with picture,
/// bottom border primary, minimal styling.
class OnyxTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const OnyxTemplate({
    super.key,
    required this.pageIndex,
    required this.pageLayout,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstPage = pageIndex == 0;
    final theme = resume.metadata.design.colors;
    final primaryColor = ColorUtils.parseColor(theme.primary, Colors.blue);
    final margin = 20.0;

    return Padding(
      padding: EdgeInsets.only(left: margin, right: margin, top: margin),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Header with bottom border
          if (isFirstPage) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: primaryColor)),
              ),
              child: TemplateHeader(resume: resume),
            ),
            const SizedBox(height: 12),
          ],

          // Main sections
          for (final section in pageLayout.main)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ResumeSection(
                sectionId: section,
                resume: resume,
                isSidebar: false,
                themeOverride: const SectionTheme(hideHeadingBorder: true),
              ),
            ),

          // Sidebar sections below
          if (!pageLayout.fullWidth)
            for (final section in pageLayout.sidebar)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ResumeSection(
                  sectionId: section,
                  resume: resume,
                  isSidebar: false,
                  themeOverride: const SectionTheme(hideHeadingBorder: true),
                ),
              ),
        ],
      ),
    );
  }
}
