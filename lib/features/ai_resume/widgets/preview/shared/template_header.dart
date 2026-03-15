import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../models/resume_data.dart';
import 'color_utils.dart';
import 'page_picture.dart';

/// Shared header builder used by all templates.
/// Each template passes its own layout configuration.
class TemplateHeader extends StatelessWidget {
  final ResumeData resume;

  // Layout
  final Axis contactsAxis; // horizontal wrap or vertical column
  final CrossAxisAlignment headerAlignment; // start, center
  final bool showPicture;
  final bool pictureInRow; // picture beside name (true) or above name (false)

  // Styling
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final double? borderRadius;
  final bool contactsSeparatorBorder; // pipe separators between contacts

  // Special slots
  final Widget? summaryWidget;
  final Widget? pictureOverride; // for absolute positioned pictures etc.
  final Widget? trailing; // for picture on the right side (rhyhorn)
  final Widget? belowContacts; // for bordered contact box (glalie)

  const TemplateHeader({
    super.key,
    required this.resume,
    this.contactsAxis = Axis.horizontal,
    this.headerAlignment = CrossAxisAlignment.start,
    this.showPicture = true,
    this.pictureInRow = true,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.decoration,
    this.borderRadius,
    this.contactsSeparatorBorder = false,
    this.summaryWidget,
    this.pictureOverride,
    this.trailing,
    this.belowContacts,
  });

  @override
  Widget build(BuildContext context) {
    final basics = resume.basics;
    final picture = resume.picture;
    final theme = resume.metadata.design.colors;
    final typography = resume.metadata.typography;
    final primaryColor = ColorUtils.parseColor(theme.primary, Colors.blue);
    final displayTextColor =
        textColor ?? ColorUtils.parseColor(theme.text, Colors.black);
    final bodySize = typography.body.fontSize;
    final headingSize = typography.heading.fontSize;
    final nameSize = headingSize + 6;

    final nameHeadline = Column(
      crossAxisAlignment: headerAlignment == CrossAxisAlignment.center
          ? .center
          : .start,
      children: [
        Text(
          basics.name,
          style: TextStyle(
            fontSize: nameSize,
            fontWeight: FontWeight.bold,
            color: displayTextColor,
          ),
          textAlign: headerAlignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
        ),
        if (basics.headline.isNotEmpty)
          Text(
            basics.headline,
            style: TextStyle(
              fontSize: bodySize + 1,
              color: displayTextColor.withValues(alpha: 0.8),
            ),
            textAlign: headerAlignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.start,
          ),
      ],
    );

    final contactItems = _buildContactItems(
      basics,
      primaryColor,
      displayTextColor,
      bodySize,
    );

    Widget contactsWidget;
    if (contactsAxis == Axis.vertical) {
      contactsWidget = Column(
        crossAxisAlignment: headerAlignment == CrossAxisAlignment.center
            ? .center
            : .start,
        children: contactItems,
      );
    } else {
      contactsWidget = Wrap(
        spacing: contactsSeparatorBorder ? 0 : 10,
        runSpacing: 2,
        alignment: headerAlignment == CrossAxisAlignment.center
            ? WrapAlignment.center
            : .start,
        children: contactItems,
      );
    }

    final pictureWidget = showPicture
        ? (pictureOverride ?? PagePicture(picture: picture, name: basics.name))
        : const SizedBox.shrink();

    // Build the main header content
    Widget headerContent;

    if (pictureInRow && showPicture) {
      // Picture beside name+contacts (most templates)
      headerContent = Column(
        crossAxisAlignment: headerAlignment,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              if (!picture.hidden && picture.url.isNotEmpty) ...[
                pictureWidget,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: headerAlignment,
                  children: [
                    nameHeadline,
                    ?summaryWidget,
                    const SizedBox(height: 8),
                    contactsWidget,
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 16), trailing!],
            ],
          ),
        ],
      );
    } else {
      // Picture above name (centered templates)
      headerContent = Column(
        crossAxisAlignment: headerAlignment,
        children: [
          if (showPicture && !picture.hidden && picture.url.isNotEmpty) ...[
            pictureWidget,
            const SizedBox(height: 8),
          ],
          nameHeadline,
          ?summaryWidget,
          const SizedBox(height: 8),
          contactsWidget,
          ?belowContacts,
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: padding,
      decoration:
          decoration ??
          (backgroundColor != null
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius != null
                      ? BorderRadius.circular(borderRadius!)
                      : null,
                )
              : null),
      child: headerContent,
    );
  }

  List<Widget> _buildContactItems(
    Basics basics,
    Color primaryColor,
    Color textColor,
    double bodySize,
  ) {
    final items = <Widget>[];
    final style = TextStyle(fontSize: bodySize, color: textColor);

    if (basics.email.isNotEmpty) {
      items.add(_contactItem(LucideIcons.mail, basics.email, textColor, style));
    }
    if (basics.phone.isNotEmpty) {
      items.add(
        _contactItem(LucideIcons.phone, basics.phone, textColor, style),
      );
    }
    if (basics.location.isNotEmpty) {
      items.add(
        _contactItem(LucideIcons.mapPin, basics.location, textColor, style),
      );
    }
    if (basics.website.url.isNotEmpty) {
      items.add(
        _contactItem(
          LucideIcons.globe,
          basics.website.label.isNotEmpty
              ? basics.website.label
              : basics.website.url,
          textColor,
          style,
        ),
      );
    }
    for (final field in basics.customFields) {
      items.add(
        _contactItem(
          _iconForName(field.icon),
          field.link.isNotEmpty ? field.text : field.text,
          textColor,
          style,
        ),
      );
    }
    return items;
  }

  Widget _contactItem(
    IconData icon,
    String text,
    Color color,
    TextStyle style,
  ) {
    final item = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: style.fontSize! * 1.2, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text, style: style, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    if (contactsSeparatorBorder) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
          ),
        ),
        child: item,
      );
    }

    if (contactsAxis == Axis.vertical) {
      return Padding(padding: const EdgeInsets.only(bottom: 4), child: item);
    }

    return item;
  }

  IconData _iconForName(String name) {
    return switch (name.toLowerCase()) {
      'phone' => LucideIcons.phone,
      'mail' || 'envelope' || 'at' => LucideIcons.mail,
      'map-pin' || 'location' => LucideIcons.mapPin,
      'globe' || 'website' => LucideIcons.globe,
      'linkedin' => LucideIcons.linkedin,
      'github' => LucideIcons.github,
      'twitter' => LucideIcons.twitter,
      'link' => LucideIcons.link,
      _ => LucideIcons.circle,
    };
  }
}
