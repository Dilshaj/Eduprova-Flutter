import 'package:flutter/material.dart';
import '../../models/resume_data.dart';
import 'skill_level_display.dart';
import 'shared/linked_title.dart';

import 'resume_section.dart' show SectionTheme;

class SectionItemRenderer extends StatelessWidget {
  final dynamic item;
  final String sectionId;
  final Color textColor;
  final Color primaryColor;
  final bool isSidebar;
  final Metadata metadata;
  final SectionTheme? themeOverride;

  const SectionItemRenderer({
    super.key,
    required this.item,
    required this.sectionId,
    required this.textColor,
    required this.primaryColor,
    required this.isSidebar,
    required this.metadata,
    this.themeOverride,
  });

  @override
  Widget build(BuildContext context) {
    final bodySize = metadata.typography.body.fontSize;
    final titleSize = bodySize + 1.0;
    final subtitleSize = bodySize - 0.5;

    switch (sectionId) {
      case 'profiles':
        return _buildProfileItem(item as ProfileItem, bodySize);
      case 'experience':
        return _buildExperienceItem(
          item as ExperienceItem,
          titleSize,
          bodySize,
          subtitleSize,
        );
      case 'education':
        return _buildEducationItem(
          item as EducationItem,
          titleSize,
          bodySize,
          subtitleSize,
        );
      case 'skills':
        return _buildSkillItem(item as SkillItem, bodySize);
      case 'projects':
        return _buildProjectItem(item as ProjectItem, titleSize, bodySize);
      case 'languages':
        return _buildLanguageItem(item as LanguageItem, bodySize, subtitleSize);
      case 'certifications':
        return _buildCertificationItem(
          item as CertificationItem,
          titleSize,
          subtitleSize,
        );
      case 'awards':
        return _buildAwardItem(item as AwardItem, titleSize, subtitleSize);
      case 'interests':
        return _buildInterestItem(item as InterestItem, bodySize);
      case 'publications':
        return _buildPublicationItem(
          item as PublicationItem,
          titleSize,
          subtitleSize,
        );
      case 'volunteer':
        return _buildVolunteerItem(
          item as VolunteerItem,
          titleSize,
          subtitleSize,
        );
      case 'references':
        return _buildReferenceItem(
          item as ReferenceItem,
          titleSize,
          bodySize,
          subtitleSize,
        );
      default:
        return _buildGenericItem(item, bodySize);
    }
  }

  Widget _buildExperienceItem(
    ExperienceItem item,
    double titleSize,
    double bodySize,
    double subtitleSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: LinkedTitle(
                  title: item.company,
                  url: item.website.url,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              if (item.period.isNotEmpty)
                Text(
                  item.period,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.position.isNotEmpty)
                Text(
                  item.position,
                  style: TextStyle(
                    fontSize: bodySize,
                    fontStyle: FontStyle.italic,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              if (item.location.isNotEmpty)
                Text(
                  item.location,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          if (item.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.description,
                style: TextStyle(
                  fontSize: bodySize - 0.5,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(
    EducationItem item,
    double titleSize,
    double bodySize,
    double subtitleSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: LinkedTitle(
                  title: item.school,
                  url: item.website.url,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              if (item.period.isNotEmpty)
                Text(
                  item.period,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.degree} in ${item.area}',
                style: TextStyle(
                  fontSize: bodySize,
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
              if (item.location.isNotEmpty)
                Text(
                  item.location,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          if (item.grade.isNotEmpty)
            Text(
              'Grade: ${item.grade}',
              style: TextStyle(
                fontSize: subtitleSize,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillItem(SkillItem item, double bodySize) {
    Color badgeColor = themeOverride?.badgeColor ?? primaryColor;
    Color badgeTextColor = themeOverride?.badgeTextColor ?? textColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w500,
              color: badgeTextColor,
            ),
          ),
          SkillLevelDisplay(
            level: item.level,
            type: metadata.design.level.type,
            icon: 'circle',
            primaryColor: badgeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(
    ProjectItem item,
    double titleSize,
    double bodySize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                item.period,
                style: TextStyle(
                  fontSize: bodySize - 0.5,
                  color: textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          if (item.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.description,
                style: TextStyle(
                  fontSize: bodySize - 0.5,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(
    LanguageItem item,
    double bodySize,
    double subtitleSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.language,
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          Text(
            item.fluency,
            style: TextStyle(
              fontSize: subtitleSize,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationItem(
    CertificationItem item,
    double titleSize,
    double subtitleSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: titleSize - 0.5,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            '${item.issuer} | ${item.date}',
            style: TextStyle(
              fontSize: subtitleSize,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardItem(
    AwardItem item,
    double titleSize,
    double subtitleSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: titleSize - 0.5,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            '${item.awarder} | ${item.date}',
            style: TextStyle(
              fontSize: subtitleSize,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestItem(InterestItem item, double bodySize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        item.name,
        style: TextStyle(fontSize: bodySize, color: textColor),
      ),
    );
  }

  Widget _buildPublicationItem(
    PublicationItem item,
    double titleSize,
    double subtitleSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: titleSize - 0.5,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            '${item.publisher} | ${item.date}',
            style: TextStyle(
              fontSize: subtitleSize,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerItem(
    VolunteerItem item,
    double titleSize,
    double subtitleSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.organization,
            style: TextStyle(
              fontSize: titleSize - 0.5,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            item.period,
            style: TextStyle(
              fontSize: subtitleSize,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(
    ReferenceItem item,
    double titleSize,
    double bodySize,
    double subtitleSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: TextStyle(
              fontSize: titleSize - 0.5,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            item.position,
            style: TextStyle(
              fontSize: bodySize,
              fontStyle: FontStyle.italic,
              color: textColor,
            ),
          ),
          if (item.phone.isNotEmpty)
            Text(
              item.phone,
              style: TextStyle(
                fontSize: subtitleSize,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(ProfileItem item, double bodySize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '${item.network}: ${item.username}',
        style: TextStyle(fontSize: bodySize, color: textColor),
      ),
    );
  }

  Widget _buildGenericItem(dynamic item, double bodySize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        item.toString(),
        style: TextStyle(fontSize: bodySize, color: textColor),
      ),
    );
  }
}
