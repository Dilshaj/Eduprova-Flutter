import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/template_header.dart';

/// Azurill: Sidebar LEFT (no bg), centered header at top,
/// timeline markers on main sections (border-left + dot).
class AzurillTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const AzurillTemplate({
    super.key,
    required this.pageIndex,
    required this.pageLayout,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstPage = pageIndex == 0;
    final layout = resume.metadata.layout;
    final sidebarWidth = layout.sidebarWidth / 100 * 595;
    final margin = 20.0;

    return Column(
      crossAxisAlignment: .start,
      children: [
        // Centered header
        if (isFirstPage)
          Padding(
            padding: EdgeInsets.only(left: margin, right: margin, top: margin),
            child: TemplateHeader(
              resume: resume,
              headerAlignment: .center,
              pictureInRow: false,
            ),
          ),

        SizedBox(height: margin),

        // Main content with sidebar
        Expanded(
          child: Row(
            crossAxisAlignment: .start,
            children: [
              // Sidebar LEFT (no bg)
              if (!pageLayout.fullWidth)
                SizedBox(
                  width: sidebarWidth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: margin),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        for (final section in pageLayout.sidebar)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ResumeSection(
                              sectionId: section,
                              resume: resume,
                              isSidebar: true,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Main
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: margin),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      for (final section in pageLayout.main)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ResumeSection(
                            sectionId: section,
                            resume: resume,
                            isSidebar: false,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
