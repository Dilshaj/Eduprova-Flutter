import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';
import '../shared/template_header.dart';

/// Chikorita: Sidebar RIGHT, solid primary background, header in MAIN
class ChikoritaTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const ChikoritaTemplate({
    super.key,
    required this.pageIndex,
    required this.pageLayout,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstPage = pageIndex == 0;
    final theme = resume.metadata.design.colors;
    final layout = resume.metadata.layout;
    final primaryColor = ColorUtils.parseColor(theme.primary, Colors.blue);
    final bgColor = ColorUtils.parseColor(theme.background, Colors.white);
    final sidebarWidth = layout.sidebarWidth / 100 * 595;
    final margin = 20.0;

    return ClipRect(
      child: Stack(
        children: [
          // Sidebar background on the RIGHT
          if (!pageLayout.fullWidth)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(color: primaryColor),
            ),

          // Content
          Row(
            crossAxisAlignment: .start,
            children: [
              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: margin,
                    right: margin,
                    top: margin,
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      if (isFirstPage) TemplateHeader(resume: resume),
                      const SizedBox(height: 16),
                      for (final section in pageLayout.main)
                        ResumeSection(
                          sectionId: section,
                          resume: resume,
                          isSidebar: false,
                          bottomPadding: 12,
                        ),
                    ],
                  ),
                ),
              ),

              // Sidebar
              if (!pageLayout.fullWidth)
                SizedBox(
                  width: sidebarWidth,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: margin / 2,
                      right: margin / 2,
                      top: margin,
                    ),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        for (final section in pageLayout.sidebar)
                          ResumeSection(
                            sectionId: section,
                            resume: resume,
                            isSidebar: true,
                            bottomPadding: 12,
                            themeOverride: SectionTheme(
                              headingColor: bgColor,
                              headingBorderColor: bgColor,
                              iconColor: bgColor,
                              textColor: bgColor,
                              badgeColor: bgColor,
                              badgeTextColor: bgColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
