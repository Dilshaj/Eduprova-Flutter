import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';
import '../shared/template_header.dart';

/// Ditgar: Sidebar LEFT, primary/20 bg, header IN sidebar with solid primary bg.
/// Summary shown at top of main area. Main section items have left border decoration.
class DitgarTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const DitgarTemplate({
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
    final showSidebar = !pageLayout.fullWidth || isFirstPage;

    return ClipRect(
      child: Stack(
        children: [
          // Sidebar background LEFT with primary/20
          if (showSidebar)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(color: primaryColor.withValues(alpha: 0.2)),
            ),

          Row(
            crossAxisAlignment: .start,
            children: [
              // Sidebar LEFT
              if (showSidebar)
                SizedBox(
                  width: sidebarWidth,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      // Header in sidebar with solid primary bg
                      if (isFirstPage)
                        TemplateHeader(
                          resume: resume,
                          backgroundColor: primaryColor,
                          textColor: bgColor,
                          padding: EdgeInsets.all(margin),
                          pictureInRow: false,
                          contactsAxis: Axis.vertical,
                          showPicture: true,
                        ),

                      // Sidebar sections
                      if (!pageLayout.fullWidth)
                        Padding(
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
                                  themeOverride: const SectionTheme(
                                    hideHeading: true,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // Summary at top of main
                    if (isFirstPage)
                      ResumeSection(
                        sectionId: 'summary',
                        resume: resume,
                        isSidebar: false,
                        bottomPadding:
                            margin, // Using margin as padding for consistency with original
                      ),

                    Padding(
                      padding: EdgeInsets.only(
                        left: margin,
                        right: margin,
                        top: margin,
                      ),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          for (final section in pageLayout.main)
                            if (section != 'summary')
                              ResumeSection(
                                sectionId: section,
                                resume: resume,
                                isSidebar: false,
                                bottomPadding: 12,
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
