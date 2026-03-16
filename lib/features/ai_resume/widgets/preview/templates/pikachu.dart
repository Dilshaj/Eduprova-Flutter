import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';
import '../shared/template_header.dart';

/// Pikachu: Sidebar LEFT, no sidebar bg, picture in sidebar,
/// header in main with rounded primary bg, bordered sections.
class PikachuTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const PikachuTemplate({
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
    final picBorderRadius = resume.picture.borderRadius;

    return Padding(
      padding: EdgeInsets.only(left: margin, right: margin, top: margin),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          // Sidebar LEFT (no bg)
          if (!pageLayout.fullWidth)
            SizedBox(
              width: sidebarWidth,
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  // Picture in sidebar
                  if (isFirstPage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: sidebarWidth,
                        child: _buildPicture(),
                      ),
                    ),

                  for (final section in pageLayout.sidebar)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ResumeSection(
                        sectionId: section,
                        resume: resume,
                        isSidebar: true,
                        headingDecoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          if (!pageLayout.fullWidth) SizedBox(width: margin),

          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                // Header with rounded primary bg
                if (isFirstPage)
                  Row(
                    children: [
                      if (pageLayout.fullWidth) ...[
                        _buildPicture(),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: TemplateHeader(
                          resume: resume,
                          backgroundColor: primaryColor,
                          textColor: bgColor,
                          borderRadius: picBorderRadius,
                          padding: EdgeInsets.all(margin),
                          showPicture: false,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(
                              picBorderRadius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                for (final section in pageLayout.main)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ResumeSection(
                      sectionId: section,
                      resume: resume,
                      isSidebar: false,
                      headingDecoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicture() {
    final picture = resume.picture;
    if (picture.hidden || picture.url.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: picture.size,
      child: AspectRatio(
        aspectRatio: picture.aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(picture.borderRadius),
            image: DecorationImage(
              image: picture.url.startsWith('http')
                  ? NetworkImage(picture.url)
                  : AssetImage(picture.url) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
