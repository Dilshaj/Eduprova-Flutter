import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';
import '../shared/template_header.dart';

/// Lapras: NO sidebar layout (single column), header with border + picture left,
/// sections in bordered rounded cards with heading floating above border.
/// Contact items have pipe separators.
class LaprasTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const LaprasTemplate({
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
      padding: .only(left: margin, right: margin, top: margin),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Header in bordered box with picture left
          if (isFirstPage)
            Container(
              padding: .all(12),
              decoration: BoxDecoration(
                border: .all(
                  color: ColorUtils.parseColor(
                    theme.text,
                    Colors.black,
                  ).withValues(alpha: 0.2),
                ),
                borderRadius: .circular(
                  resume.picture.borderRadius.clamp(0, 30),
                ),
              ),
              child: TemplateHeader(
                resume: resume,
                contactsSeparatorBorder: true,
              ),
            ),

          const SizedBox(height: 12),

          // Main sections in bordered cards
          for (final section in pageLayout.main)
            _buildCardSection(section, primaryColor),

          // Sidebar sections
          if (!pageLayout.fullWidth)
            for (final section in pageLayout.sidebar)
              _buildCardSection(section, primaryColor),
        ],
      ),
    );
  }

  Widget _buildCardSection(String sectionId, Color primaryColor) {
    final textColor = ColorUtils.parseColor(
      resume.metadata.design.colors.text,
      Colors.black,
    );
    final borderRadius = resume.picture.borderRadius.clamp(0.0, 30.0);

    return ResumeSection(
      sectionId: sectionId,
      resume: resume,
      isSidebar: false,
      bottomPadding: 16,
      padding: .all(12),
      decoration: BoxDecoration(
        border: .all(color: textColor.withValues(alpha: 0.1)),
        borderRadius: .circular(borderRadius),
        color: ColorUtils.parseColor(
          resume.metadata.design.colors.background,
          Colors.white,
        ),
      ),
    );
  }
}
