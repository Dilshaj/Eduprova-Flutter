import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import '../resume_section.dart';
import '../shared/color_utils.dart';
import '../shared/template_header.dart';

/// Glalie: Sidebar LEFT, primary/20 bg, header IN sidebar centered,
/// contacts inside bordered box, heading border-bottom.
class GlalieTemplate extends StatelessWidget {
  final int pageIndex;
  final PageLayout pageLayout;
  final ResumeData resume;

  const GlalieTemplate({
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
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: margin / 2,
                      right: margin / 2,
                      top: margin,
                    ),
                    child: Column(
                      crossAxisAlignment: .center,
                      children: [
                        // Header centered in sidebar with bordered contacts
                        if (isFirstPage)
                          TemplateHeader(
                            resume: resume,
                            headerAlignment: .center,
                            pictureInRow: false,
                            contactsAxis: Axis.vertical,
                            belowContacts: _buildBorderedContacts(primaryColor),
                          ),

                        const SizedBox(height: 12),

                        // Sidebar sections
                        if (!pageLayout.fullWidth)
                          Column(
                            crossAxisAlignment: .start,
                            children: [
                              for (final section in pageLayout.sidebar)
                                ResumeSection(
                                  sectionId: section,
                                  resume: resume,
                                  isSidebar: true,
                                  bottomPadding: 12,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

              // Main
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
            ],
          ),
        ],
      ),
    );
  }

  /// Bordered contact details box in sidebar
  Widget _buildBorderedContacts(Color primaryColor) {
    final basics = resume.basics;
    final bodySize = resume.metadata.typography.body.fontSize;
    final textColor = ColorUtils.parseColor(
      resume.metadata.design.colors.text,
      Colors.black,
    );
    final style = TextStyle(fontSize: bodySize, color: textColor);
    final borderRadius = resume.picture.borderRadius / 4;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: .start,
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
      ),
    );
  }

  Widget _contactItem(
    IconData icon,
    String text,
    TextStyle style,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: style.fontSize! * 1.2, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text, style: style, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
