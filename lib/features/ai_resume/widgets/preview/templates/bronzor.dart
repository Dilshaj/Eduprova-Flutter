import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';
import '../shared/template_header.dart';

/// Bronzor: NO sidebar, centered header, sections use grid-like layout
/// (heading on left, content on right). Heading border-top.
class BronzorTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const BronzorTemplate({
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
        crossAxisAlignment: .center,
        children: [
          if (isFirstPage)
            TemplateHeader(
              resume: resume,
              headerAlignment: .center,
              pictureInRow: false,
            ),

          const SizedBox(height: 12),

          // Main sections with border-top headings
          for (final section in pageLayout.main)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: primaryColor)),
              ),
              child: ResumeSection(
                sectionId: section,
                resume: resume,
                isSidebar: false,
                themeOverride: SectionTheme(
                  headingLeft: true,
                  hideHeadingBorder: true,
                ),
              ),
            ),

          // Sidebar sections below
          if (!pageLayout.fullWidth)
            for (final section in pageLayout.sidebar)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: primaryColor)),
                ),
                child: ResumeSection(
                  sectionId: section,
                  resume: resume,
                  isSidebar: false,
                  themeOverride: SectionTheme(
                    headingLeft: true,
                    hideHeadingBorder: true,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
