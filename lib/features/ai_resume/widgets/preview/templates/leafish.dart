import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';

/// Leafish: Main LEFT, Sidebar RIGHT (reverse of most),
/// header full-width with primary/10 bg, summary inline in header,
/// contacts in separate primary/10 bar below. Section heading border-b.
class LeafishTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const LeafishTemplate({
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
    final textColor = ColorUtils.parseColor(theme.text, Colors.black);
    final sidebarWidth = layout.sidebarWidth / 100 * 595;
    final margin = 20.0;

    return Column(
      crossAxisAlignment: .start,
      children: [
        if (isFirstPage) ...[
          // Header area with primary/10 bg
          Container(
            width: double.infinity,
            color: primaryColor.withValues(alpha: 0.1),
            padding: EdgeInsets.all(margin),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                _buildPicture(),
                if (!resume.picture.hidden && resume.picture.url.isNotEmpty)
                  SizedBox(width: margin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        resume.basics.name,
                        style: TextStyle(
                          fontSize:
                              resume.metadata.typography.heading.fontSize + 6,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (resume.basics.headline.isNotEmpty)
                        Text(
                          resume.basics.headline,
                          style: TextStyle(
                            fontSize:
                                resume.metadata.typography.body.fontSize + 1,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      // Summary inline
                      if (resume.summary.content.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          resume.summary.content,
                          style: TextStyle(
                            fontSize: resume.metadata.typography.body.fontSize,
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contacts bar with slightly darker primary/10
          Container(
            width: double.infinity,
            color: primaryColor.withValues(alpha: 0.1),
            padding: EdgeInsets.symmetric(
              horizontal: margin,
              vertical: margin / 2,
            ),
            child: _buildContacts(textColor),
          ),
        ],

        // Content: Main LEFT, Sidebar RIGHT
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: margin, right: margin, top: margin),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                // Main content (LEFT)
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      for (final section in pageLayout.main)
                        if (section != 'summary')
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

                // Sidebar RIGHT (no bg)
                if (!pageLayout.fullWidth) ...[
                  SizedBox(width: margin),
                  SizedBox(
                    width: sidebarWidth,
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        for (final section in pageLayout.sidebar)
                          if (section != 'summary')
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
                ],
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildContacts(Color textColor) {
    final basics = resume.basics;
    final bodySize = resume.metadata.typography.body.fontSize;
    final style = TextStyle(fontSize: bodySize, color: textColor);

    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        if (basics.email.isNotEmpty)
          _contactItem(Icons.email_outlined, basics.email, style, textColor),
        if (basics.phone.isNotEmpty)
          _contactItem(Icons.phone_outlined, basics.phone, style, textColor),
        if (basics.location.isNotEmpty)
          _contactItem(
            Icons.location_on_outlined,
            basics.location,
            style,
            textColor,
          ),
        if (basics.website.url.isNotEmpty)
          _contactItem(
            Icons.language,
            basics.website.label.isNotEmpty
                ? basics.website.label
                : basics.website.url,
            style,
            textColor,
          ),
      ],
    );
  }

  Widget _contactItem(
    IconData icon,
    String text,
    TextStyle style,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: style.fontSize! * 1.2, color: color),
        const SizedBox(width: 4),
        Text(text, style: style),
      ],
    );
  }
}
