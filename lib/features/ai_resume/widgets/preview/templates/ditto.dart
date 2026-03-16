import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';

/// Ditto: Sidebar LEFT (no bg), full-width header bar with primary bg,
/// picture positioned in sidebar area, contacts below header in main area.
class DittoTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const DittoTemplate({
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

    return Column(
      crossAxisAlignment: .start,
      children: [
        // Full-width header bar with primary bg
        if (isFirstPage) ...[
          Container(
            color: primaryColor,
            child: Row(
              children: [
                // Picture area (sidebar width)
                SizedBox(
                  width: sidebarWidth,
                  child: Padding(
                    padding: EdgeInsets.only(left: margin),
                    child: _buildPicture(),
                  ),
                ),
                // Name + headline
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(margin),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          resume.basics.name,
                          style: TextStyle(
                            fontSize:
                                resume.metadata.typography.heading.fontSize + 6,
                            fontWeight: FontWeight.bold,
                            color: bgColor,
                          ),
                        ),
                        if (resume.basics.headline.isNotEmpty)
                          Text(
                            resume.basics.headline,
                            style: TextStyle(
                              fontSize:
                                  resume.metadata.typography.body.fontSize + 1,
                              color: bgColor.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contacts row below header
          Row(
            children: [
              SizedBox(width: sidebarWidth), // spacer for sidebar
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: margin,
                    right: margin,
                    top: 12,
                  ),
                  child: _buildContacts(),
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: margin),

        // Content area
        Expanded(
          child: Row(
            crossAxisAlignment: .start,
            children: [
              // Sidebar LEFT (no bg)
              if (!pageLayout.fullWidth)
                SizedBox(
                  width: sidebarWidth,
                  child: Padding(
                    padding: EdgeInsets.only(left: margin),
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

  Widget _buildContacts() {
    final basics = resume.basics;
    final bodySize = resume.metadata.typography.body.fontSize;
    final textColor = ColorUtils.parseColor(
      resume.metadata.design.colors.text,
      Colors.black,
    );
    final style = TextStyle(fontSize: bodySize, color: textColor);

    return Wrap(
      spacing: 10,
      runSpacing: 2,
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
