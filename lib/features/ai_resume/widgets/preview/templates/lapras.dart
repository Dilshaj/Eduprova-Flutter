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
      padding: EdgeInsets.only(left: margin, right: margin, top: margin),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Header in bordered box with picture left
          if (isFirstPage)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorUtils.parseColor(
                    theme.text,
                    Colors.black,
                  ).withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(
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
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCardSection(section, primaryColor),
            ),

          // Sidebar sections
          if (!pageLayout.fullWidth)
            for (final section in pageLayout.sidebar)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCardSection(section, primaryColor),
              ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(borderRadius),
        color: ColorUtils.parseColor(
          resume.metadata.design.colors.background,
          Colors.white,
        ),
      ),
      child: ResumeSection(
        sectionId: sectionId,
        resume: resume,
        isSidebar: false,
      ),
    );
  }
}
