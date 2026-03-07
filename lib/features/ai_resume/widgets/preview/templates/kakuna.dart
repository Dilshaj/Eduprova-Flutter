import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';
import '../shared/template_header.dart';

/// Kakuna: NO sidebar, single column, centered header, sections stacked vertically.
/// Section headings: border-bottom + centered text.
class KakunaTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const KakunaTemplate({
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

          // Main sections
          for (final section in pageLayout.main)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ResumeSection(
                sectionId: section,
                resume: resume,
                isSidebar: false,
                alignment: .center,
                headingDecoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: primaryColor)),
                ),
              ),
            ),

          // Sidebar sections below (no sidebar layout)
          if (!pageLayout.fullWidth)
            for (final section in pageLayout.sidebar)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ResumeSection(
                  sectionId: section,
                  resume: resume,
                  isSidebar: false,
                  alignment: .center,
                  headingDecoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: primaryColor)),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
