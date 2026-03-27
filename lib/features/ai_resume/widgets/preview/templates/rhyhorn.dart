import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/template_header.dart';

/// Rhyhorn: NO sidebar, header with name/contacts LEFT and picture RIGHT,
/// contact items have right-border pipe separators. Section heading border-b.
class RhyhornTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const RhyhornTemplate({
    super.key,
    required this.pageIndex,
    required this.pageLayout,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstPage = pageIndex == 0;
    final margin = 20.0;

    return Padding(
      padding: EdgeInsets.only(left: margin, right: margin, top: margin),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (isFirstPage)
            TemplateHeader(
              resume: resume,
              contactsSeparatorBorder: true,
              trailing: _buildPicture(),
              showPicture: false,
            ),

          const SizedBox(height: 12),

          // Main sections
          for (final section in pageLayout.main)
            ResumeSection(
              sectionId: section,
              resume: resume,
              isSidebar: false,
              bottomPadding: 12,
            ),

          // Sidebar sections below
          if (!pageLayout.fullWidth)
            for (final section in pageLayout.sidebar)
              ResumeSection(
                sectionId: section,
                resume: resume,
                isSidebar: false,
                bottomPadding: 12,
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
