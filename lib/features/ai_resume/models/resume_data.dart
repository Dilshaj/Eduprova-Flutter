class ResumeData {
  final Picture picture;
  final Basics basics;
  final Summary summary;
  final Sections sections;
  final List<CustomSection> customSections;
  final Metadata metadata;

  ResumeData({
    required this.picture,
    required this.basics,
    required this.summary,
    required this.sections,
    required this.customSections,
    required this.metadata,
  });

  factory ResumeData.fromJson(Map<String, dynamic> json) {
    return ResumeData(
      picture: Picture.fromJson(json['picture'] ?? {}),
      basics: Basics.fromJson(json['basics'] ?? {}),
      summary: Summary.fromJson(json['summary'] ?? {}),
      sections: Sections.fromJson(json['sections'] ?? {}),
      customSections: (json['customSections'] as List? ?? [])
          .map((e) => CustomSection.fromJson(e))
          .toList(),
      metadata: Metadata.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'picture': picture.toJson(),
    'basics': basics.toJson(),
    'summary': summary.toJson(),
    'sections': sections.toJson(),
    'customSections': customSections.map((e) => e.toJson()).toList(),
    'metadata': metadata.toJson(),
  };

  ResumeData copyWith({
    Picture? picture,
    Basics? basics,
    Summary? summary,
    Sections? sections,
    List<CustomSection>? customSections,
    Metadata? metadata,
  }) {
    return ResumeData(
      picture: picture ?? this.picture,
      basics: basics ?? this.basics,
      summary: summary ?? this.summary,
      sections: sections ?? this.sections,
      customSections: customSections ?? this.customSections,
      metadata: metadata ?? this.metadata,
    );
  }

  factory ResumeData.empty() => ResumeData(
    picture: Picture.empty(),
    basics: Basics.empty(),
    summary: Summary.empty(),
    sections: Sections.empty(),
    customSections: [],
    metadata: Metadata.defaultData(),
  );
}

class Picture {
  final bool hidden;
  final String url;
  final double size;
  final double rotation;
  final double aspectRatio;
  final double borderRadius;
  final String borderColor;
  final double borderWidth;
  final String shadowColor;
  final double shadowWidth;

  Picture({
    required this.hidden,
    required this.url,
    required this.size,
    required this.rotation,
    required this.aspectRatio,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
    required this.shadowColor,
    required this.shadowWidth,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      hidden: json['hidden'] ?? false,
      url: json['url'] ?? '',
      size: (json['size'] as num? ?? 80).toDouble(),
      rotation: (json['rotation'] as num? ?? 0).toDouble(),
      aspectRatio: (json['aspectRatio'] as num? ?? 1).toDouble(),
      borderRadius: (json['borderRadius'] as num? ?? 0).toDouble(),
      borderColor: json['borderColor'] ?? 'rgba(0, 0, 0, 0.5)',
      borderWidth: (json['borderWidth'] as num? ?? 0).toDouble(),
      shadowColor: json['shadowColor'] ?? 'rgba(0, 0, 0, 0.5)',
      shadowWidth: (json['shadowWidth'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'hidden': hidden,
    'url': url,
    'size': size,
    'rotation': rotation,
    'aspectRatio': aspectRatio,
    'borderRadius': borderRadius,
    'borderColor': borderColor,
    'borderWidth': borderWidth,
    'shadowColor': shadowColor,
    'shadowWidth': shadowWidth,
  };

  factory Picture.empty() => Picture(
    hidden: false,
    url: '',
    size: 80,
    rotation: 0,
    aspectRatio: 1,
    borderRadius: 0,
    borderColor: 'rgba(0, 0, 0, 0.5)',
    borderWidth: 0,
    shadowColor: 'rgba(0, 0, 0, 0.5)',
    shadowWidth: 0,
  );

  Picture copyWith({
    bool? hidden,
    String? url,
    double? size,
    double? rotation,
    double? aspectRatio,
    double? borderRadius,
    String? borderColor,
    double? borderWidth,
    String? shadowColor,
    double? shadowWidth,
  }) {
    return Picture(
      hidden: hidden ?? this.hidden,
      url: url ?? this.url,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowWidth: shadowWidth ?? this.shadowWidth,
    );
  }
}

class Url {
  final String url;
  final String label;

  Url({required this.url, required this.label});

  factory Url.fromJson(Map<String, dynamic> json) {
    return Url(url: json['url'] ?? '', label: json['label'] ?? '');
  }

  Map<String, dynamic> toJson() => {'url': url, 'label': label};

  factory Url.empty() => Url(url: '', label: '');
}

class CustomField {
  final String id;
  final String icon;
  final String text;
  final String link;

  CustomField({
    required this.id,
    required this.icon,
    required this.text,
    required this.link,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      id: json['id'] ?? '',
      icon: json['icon'] ?? '',
      text: json['text'] ?? '',
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'icon': icon,
    'text': text,
    'link': link,
  };
}

class Basics {
  final String name;
  final String headline;
  final String email;
  final String phone;
  final String location;
  final Url website;
  final List<CustomField> customFields;

  Basics({
    required this.name,
    required this.headline,
    required this.email,
    required this.phone,
    required this.location,
    required this.website,
    required this.customFields,
  });

  factory Basics.fromJson(Map<String, dynamic> json) {
    return Basics(
      name: json['name'] ?? '',
      headline: json['headline'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
      customFields: (json['customFields'] as List? ?? [])
          .map((e) => CustomField.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'headline': headline,
    'email': email,
    'phone': phone,
    'location': location,
    'website': website.toJson(),
    'customFields': customFields.map((e) => e.toJson()).toList(),
  };

  factory Basics.empty() => Basics(
    name: '',
    headline: '',
    email: '',
    phone: '',
    location: '',
    website: Url.empty(),
    customFields: [],
  );
}

class Summary {
  final String title;
  final int columns;
  final bool hidden;
  final String content;

  Summary({
    required this.title,
    required this.columns,
    required this.hidden,
    required this.content,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      title: json['title'] ?? '',
      columns: json['columns'] ?? 1,
      hidden: json['hidden'] ?? false,
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'columns': columns,
    'hidden': hidden,
    'content': content,
  };

  factory Summary.empty() =>
      Summary(title: '', columns: 1, hidden: false, content: '');
}

abstract class ResumeItem {
  final String id;
  final bool hidden;

  ResumeItem({required this.id, required this.hidden});

  Map<String, dynamic> toJson();
}

class ExperienceItem extends ResumeItem {
  final String company;
  final String position;
  final String location;
  final String period;
  final Url website;
  final String description;

  ExperienceItem({
    required super.id,
    required super.hidden,
    required this.company,
    required this.position,
    required this.location,
    required this.period,
    required this.website,
    required this.description,
  });

  factory ExperienceItem.fromJson(Map<String, dynamic> json) {
    return ExperienceItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      location: json['location'] ?? '',
      period: json['period'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'company': company,
    'position': position,
    'location': location,
    'period': period,
    'website': website.toJson(),
    'description': description,
  };

  ExperienceItem copyWith({
    String? id,
    bool? hidden,
    String? company,
    String? position,
    String? location,
    String? period,
    Url? website,
    String? description,
  }) {
    return ExperienceItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      company: company ?? this.company,
      position: position ?? this.position,
      location: location ?? this.location,
      period: period ?? this.period,
      website: website ?? this.website,
      description: description ?? this.description,
    );
  }
}

class EducationItem extends ResumeItem {
  final String school;
  final String degree;
  final String area;
  final String grade;
  final String location;
  final String period;
  final Url website;
  final String description;

  EducationItem({
    required super.id,
    required super.hidden,
    required this.school,
    required this.degree,
    required this.area,
    required this.grade,
    required this.location,
    required this.period,
    required this.website,
    required this.description,
  });

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      school: json['school'] ?? '',
      degree: json['degree'] ?? '',
      area: json['area'] ?? '',
      grade: json['grade'] ?? '',
      location: json['location'] ?? '',
      period: json['period'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'school': school,
    'degree': degree,
    'area': area,
    'grade': grade,
    'location': location,
    'period': period,
    'website': website.toJson(),
    'description': description,
  };

  EducationItem copyWith({
    String? id,
    bool? hidden,
    String? school,
    String? degree,
    String? area,
    String? grade,
    String? location,
    String? period,
    Url? website,
    String? description,
  }) {
    return EducationItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      school: school ?? this.school,
      degree: degree ?? this.degree,
      area: area ?? this.area,
      grade: grade ?? this.grade,
      location: location ?? this.location,
      period: period ?? this.period,
      website: website ?? this.website,
      description: description ?? this.description,
    );
  }
}

class SkillItem extends ResumeItem {
  final String icon;
  final String name;
  final String proficiency;
  final int level;
  final List<String> keywords;

  SkillItem({
    required super.id,
    required super.hidden,
    required this.icon,
    required this.name,
    required this.proficiency,
    required this.level,
    required this.keywords,
  });

  factory SkillItem.fromJson(Map<String, dynamic> json) {
    return SkillItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      icon: json['icon'] ?? '',
      name: json['name'] ?? '',
      proficiency: json['proficiency'] ?? '',
      level: json['level'] ?? 0,
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'icon': icon,
    'name': name,
    'proficiency': proficiency,
    'level': level,
    'keywords': keywords,
  };

  SkillItem copyWith({
    String? id,
    bool? hidden,
    String? icon,
    String? name,
    String? proficiency,
    int? level,
    List<String>? keywords,
  }) {
    return SkillItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      proficiency: proficiency ?? this.proficiency,
      level: level ?? this.level,
      keywords: keywords ?? this.keywords,
    );
  }
}

class ProjectItem extends ResumeItem {
  final String name;
  final String period;
  final Url website;
  final String description;

  ProjectItem({
    required super.id,
    required super.hidden,
    required this.name,
    required this.period,
    required this.website,
    required this.description,
  });

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    return ProjectItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      name: json['name'] ?? '',
      period: json['period'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'name': name,
    'period': period,
    'website': website.toJson(),
    'description': description,
  };

  ProjectItem copyWith({
    String? id,
    bool? hidden,
    String? name,
    String? period,
    Url? website,
    String? description,
  }) {
    return ProjectItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      name: name ?? this.name,
      period: period ?? this.period,
      website: website ?? this.website,
      description: description ?? this.description,
    );
  }
}

class CertificationItem extends ResumeItem {
  final String title;
  final String issuer;
  final String date;
  final Url website;
  final String description;

  CertificationItem({
    required super.id,
    required super.hidden,
    required this.title,
    required this.issuer,
    required this.date,
    required this.website,
    required this.description,
  });

  factory CertificationItem.fromJson(Map<String, dynamic> json) {
    return CertificationItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      title: json['title'] ?? '',
      issuer: json['issuer'] ?? '',
      date: json['date'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'title': title,
    'issuer': issuer,
    'date': date,
    'website': website.toJson(),
    'description': description,
  };

  CertificationItem copyWith({
    String? id,
    bool? hidden,
    String? title,
    String? issuer,
    String? date,
    Url? website,
    String? description,
  }) {
    return CertificationItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      title: title ?? this.title,
      issuer: issuer ?? this.issuer,
      date: date ?? this.date,
      website: website ?? this.website,
      description: description ?? this.description,
    );
  }
}

class AwardItem extends ResumeItem {
  final String title;
  final String awarder;
  final String date;
  final Url website;
  final String description;

  AwardItem({
    required super.id,
    required super.hidden,
    required this.title,
    required this.awarder,
    required this.date,
    required this.website,
    required this.description,
  });

  factory AwardItem.fromJson(Map<String, dynamic> json) {
    return AwardItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      title: json['title'] ?? '',
      awarder: json['awarder'] ?? '',
      date: json['date'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'title': title,
    'awarder': awarder,
    'date': date,
    'website': website.toJson(),
    'description': description,
  };

  AwardItem copyWith({
    String? id,
    bool? hidden,
    String? title,
    String? awarder,
    String? date,
    Url? website,
    String? description,
  }) {
    return AwardItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      title: title ?? this.title,
      awarder: awarder ?? this.awarder,
      date: date ?? this.date,
      website: website ?? this.website,
      description: description ?? this.description,
    );
  }
}

class InterestItem extends ResumeItem {
  final String icon;
  final String name;
  final List<String> keywords;

  InterestItem({
    required super.id,
    required super.hidden,
    required this.icon,
    required this.name,
    required this.keywords,
  });

  factory InterestItem.fromJson(Map<String, dynamic> json) {
    return InterestItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      icon: json['icon'] ?? '',
      name: json['name'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'icon': icon,
    'name': name,
    'keywords': keywords,
  };

  InterestItem copyWith({
    String? id,
    bool? hidden,
    String? icon,
    String? name,
    List<String>? keywords,
  }) {
    return InterestItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      keywords: keywords ?? this.keywords,
    );
  }
}

class LanguageItem extends ResumeItem {
  final String language;
  final String fluency;
  final int level;

  LanguageItem({
    required super.id,
    required super.hidden,
    required this.language,
    required this.fluency,
    required this.level,
  });

  factory LanguageItem.fromJson(Map<String, dynamic> json) {
    return LanguageItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      language: json['language'] ?? '',
      fluency: json['fluency'] ?? '',
      level: json['level'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'language': language,
    'fluency': fluency,
    'level': level,
  };

  LanguageItem copyWith({
    String? id,
    bool? hidden,
    String? language,
    String? fluency,
    int? level,
  }) {
    return LanguageItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      language: language ?? this.language,
      fluency: fluency ?? this.fluency,
      level: level ?? this.level,
    );
  }
}

class ProfileItem extends ResumeItem {
  final String icon;
  final String network;
  final String username;
  final Url website;

  ProfileItem({
    required super.id,
    required super.hidden,
    required this.icon,
    required this.network,
    required this.username,
    required this.website,
  });

  factory ProfileItem.fromJson(Map<String, dynamic> json) {
    return ProfileItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      icon: json['icon'] ?? '',
      network: json['network'] ?? '',
      username: json['username'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'icon': icon,
    'network': network,
    'username': username,
    'website': website.toJson(),
  };
}

class Section<T extends ResumeItem> {
  final String title;
  final int columns;
  final bool hidden;
  final List<T> items;

  Section({
    required this.title,
    required this.columns,
    required this.hidden,
    required this.items,
  });

  factory Section.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return Section(
      title: json['title'] ?? '',
      columns: json['columns'] ?? 1,
      hidden: json['hidden'] ?? false,
      items: (json['items'] as List? ?? [])
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'columns': columns,
    'hidden': hidden,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class PublicationItem extends ResumeItem {
  final String title;
  final String publisher;
  final String date;
  final Url website;
  final String description;

  PublicationItem({
    required super.id,
    required super.hidden,
    required this.title,
    required this.publisher,
    required this.date,
    required this.website,
    required this.description,
  });

  factory PublicationItem.fromJson(Map<String, dynamic> json) {
    return PublicationItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      title: json['title'] ?? '',
      publisher: json['publisher'] ?? '',
      date: json['date'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'title': title,
    'publisher': publisher,
    'date': date,
    'website': website.toJson(),
    'description': description,
  };

  PublicationItem copyWith({
    String? id,
    bool? hidden,
    String? title,
    String? publisher,
    String? date,
    Url? website,
    String? description,
  }) {
    return PublicationItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      title: title ?? this.title,
      publisher: publisher ?? this.publisher,
      date: date ?? this.date,
      website: website ?? this.website,
      description: description ?? this.description,
    );
  }
}

class ReferenceItem extends ResumeItem {
  final String name;
  final String position;
  final String phone;
  final Url website;
  final String description;

  ReferenceItem({
    required super.id,
    required super.hidden,
    required this.name,
    required this.position,
    required this.phone,
    required this.website,
    required this.description,
  });

  factory ReferenceItem.fromJson(Map<String, dynamic> json) {
    return ReferenceItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      phone: json['phone'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'name': name,
    'position': position,
    'phone': phone,
    'website': website.toJson(),
    'description': description,
  };

  ReferenceItem copyWith({
    String? id,
    bool? hidden,
    String? name,
    String? position,
    String? phone,
    Url? website,
    String? description,
  }) {
    return ReferenceItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      name: name ?? this.name,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      description: description ?? this.description,
    );
  }
}

class VolunteerItem extends ResumeItem {
  final String organization;
  final String location;
  final String period;
  final Url website;
  final String description;

  VolunteerItem({
    required super.id,
    required super.hidden,
    required this.organization,
    required this.location,
    required this.period,
    required this.website,
    required this.description,
  });

  factory VolunteerItem.fromJson(Map<String, dynamic> json) {
    return VolunteerItem(
      id: json['id'] ?? '',
      hidden: json['hidden'] ?? false,
      organization: json['organization'] ?? '',
      location: json['location'] ?? '',
      period: json['period'] ?? '',
      website: Url.fromJson(json['website'] ?? {}),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'hidden': hidden,
    'organization': organization,
    'location': location,
    'period': period,
    'website': website.toJson(),
    'description': description,
  };

  VolunteerItem copyWith({
    String? id,
    bool? hidden,
    String? organization,
    String? location,
    String? period,
    Url? website,
    String? description,
  }) {
    return VolunteerItem(
      id: id ?? this.id,
      hidden: hidden ?? this.hidden,
      organization: organization ?? this.organization,
      location: location ?? this.location,
      period: period ?? this.period,
      website: website ?? this.website,
      description: description ?? this.description,
    );
  }
}

class Sections {
  final Section<ProfileItem> profiles;
  final Section<ExperienceItem> experience;
  final Section<EducationItem> education;
  final Section<ProjectItem> projects;
  final Section<SkillItem> skills;
  final Section<LanguageItem> languages;
  final Section<CertificationItem> certifications;
  final Section<AwardItem> awards;
  final Section<InterestItem> interests;
  final Section<PublicationItem> publications;
  final Section<VolunteerItem> volunteer;
  final Section<ReferenceItem> references;

  Sections({
    required this.profiles,
    required this.experience,
    required this.education,
    required this.projects,
    required this.skills,
    required this.languages,
    required this.certifications,
    required this.awards,
    required this.interests,
    required this.publications,
    required this.volunteer,
    required this.references,
  });

  factory Sections.fromJson(Map<String, dynamic> json) {
    return Sections(
      profiles: Section.fromJson(
        json['profiles'] ?? {},
        (e) => ProfileItem.fromJson(e),
      ),
      experience: Section.fromJson(
        json['experience'] ?? {},
        (e) => ExperienceItem.fromJson(e),
      ),
      education: Section.fromJson(
        json['education'] ?? {},
        (e) => EducationItem.fromJson(e),
      ),
      projects: Section.fromJson(
        json['projects'] ?? {},
        (e) => ProjectItem.fromJson(e),
      ),
      skills: Section.fromJson(
        json['skills'] ?? {},
        (e) => SkillItem.fromJson(e),
      ),
      languages: Section.fromJson(
        json['languages'] ?? {},
        (e) => LanguageItem.fromJson(e),
      ),
      certifications: Section.fromJson(
        json['certifications'] ?? {},
        (e) => CertificationItem.fromJson(e),
      ),
      awards: Section.fromJson(
        json['awards'] ?? {},
        (e) => AwardItem.fromJson(e),
      ),
      interests: Section.fromJson(
        json['interests'] ?? {},
        (e) => InterestItem.fromJson(e),
      ),
      publications: Section.fromJson(
        json['publications'] ?? {},
        (e) => PublicationItem.fromJson(e),
      ),
      volunteer: Section.fromJson(
        json['volunteer'] ?? {},
        (e) => VolunteerItem.fromJson(e),
      ),
      references: Section.fromJson(
        json['references'] ?? {},
        (e) => ReferenceItem.fromJson(e),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'profiles': profiles.toJson(),
    'experience': experience.toJson(),
    'education': education.toJson(),
    'projects': projects.toJson(),
    'skills': skills.toJson(),
    'languages': languages.toJson(),
    'certifications': certifications.toJson(),
    'awards': awards.toJson(),
    'interests': interests.toJson(),
    'publications': publications.toJson(),
    'volunteer': volunteer.toJson(),
    'references': references.toJson(),
  };

  Sections copyWith({
    Section<ProfileItem>? profiles,
    Section<ExperienceItem>? experience,
    Section<EducationItem>? education,
    Section<ProjectItem>? projects,
    Section<SkillItem>? skills,
    Section<LanguageItem>? languages,
    Section<CertificationItem>? certifications,
    Section<AwardItem>? awards,
    Section<InterestItem>? interests,
    Section<PublicationItem>? publications,
    Section<VolunteerItem>? volunteer,
    Section<ReferenceItem>? references,
  }) {
    return Sections(
      profiles: profiles ?? this.profiles,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      projects: projects ?? this.projects,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      certifications: certifications ?? this.certifications,
      awards: awards ?? this.awards,
      interests: interests ?? this.interests,
      publications: publications ?? this.publications,
      volunteer: volunteer ?? this.volunteer,
      references: references ?? this.references,
    );
  }

  factory Sections.empty() => Sections(
    profiles: Section(title: '', columns: 1, hidden: false, items: []),
    experience: Section(title: '', columns: 1, hidden: false, items: []),
    education: Section(title: '', columns: 1, hidden: false, items: []),
    projects: Section(title: '', columns: 1, hidden: false, items: []),
    skills: Section(title: '', columns: 1, hidden: false, items: []),
    languages: Section(title: '', columns: 1, hidden: false, items: []),
    certifications: Section(title: '', columns: 1, hidden: false, items: []),
    awards: Section(title: '', columns: 1, hidden: false, items: []),
    interests: Section(title: '', columns: 1, hidden: false, items: []),
    publications: Section(title: '', columns: 1, hidden: false, items: []),
    volunteer: Section(title: '', columns: 1, hidden: false, items: []),
    references: Section(title: '', columns: 1, hidden: false, items: []),
  );
}

class CustomSection extends Section<ResumeItem> {
  final String id;
  final String type;

  CustomSection({
    required super.title,
    required super.columns,
    required super.hidden,
    required super.items,
    required this.id,
    required this.type,
  });

  factory CustomSection.fromJson(Map<String, dynamic> json) {
    // This is a bit complex as items can be of different types
    // Simplifying for now as custom sections are secondary
    return CustomSection(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      columns: json['columns'] ?? 1,
      hidden: json['hidden'] ?? false,
      items: [], // Placeholder
    );
  }

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'id': id, 'type': type};
}

class Metadata {
  final String template;
  final Layout layout;
  final Css css;
  final PageSettings page;
  final Design design;
  final Typography typography;
  final String notes;

  Metadata({
    required this.template,
    required this.layout,
    required this.css,
    required this.page,
    required this.design,
    required this.typography,
    required this.notes,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      template: json['template'] ?? 'chikorita',
      layout: Layout.fromJson(json['layout'] ?? {}),
      css: Css.fromJson(json['css'] ?? {}),
      page: PageSettings.fromJson(json['page'] ?? {}),
      design: Design.fromJson(json['design'] ?? {}),
      typography: Typography.fromJson(json['typography'] ?? {}),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'template': template,
    'layout': layout.toJson(),
    'css': css.toJson(),
    'page': page.toJson(),
    'design': design.toJson(),
    'typography': typography.toJson(),
    'notes': notes,
  };

  factory Metadata.defaultData() => Metadata(
    template: 'chikorita',
    layout: Layout.empty(),
    css: Css.empty(),
    page: PageSettings.empty(),
    design: Design.empty(),
    typography: Typography.empty(),
    notes: '',
  );

  Metadata copyWith({
    String? template,
    Layout? layout,
    Css? css,
    PageSettings? page,
    Design? design,
    Typography? typography,
    String? notes,
  }) {
    return Metadata(
      template: template ?? this.template,
      layout: layout ?? this.layout,
      css: css ?? this.css,
      page: page ?? this.page,
      design: design ?? this.design,
      typography: typography ?? this.typography,
      notes: notes ?? this.notes,
    );
  }
}

class Css {
  final bool enabled;
  final String value;

  Css({required this.enabled, required this.value});

  factory Css.fromJson(Map<String, dynamic> json) {
    return Css(enabled: json['enabled'] ?? false, value: json['value'] ?? '');
  }

  Map<String, dynamic> toJson() => {'enabled': enabled, 'value': value};

  factory Css.empty() => Css(enabled: false, value: '');

  Css copyWith({bool? enabled, String? value}) {
    return Css(enabled: enabled ?? this.enabled, value: value ?? this.value);
  }
}

class PageSettings {
  final double gapX;
  final double gapY;
  final double marginX;
  final double marginY;
  final String format;
  final String locale;
  final bool hideIcons;

  PageSettings({
    required this.gapX,
    required this.gapY,
    required this.marginX,
    required this.marginY,
    required this.format,
    required this.locale,
    required this.hideIcons,
  });

  factory PageSettings.fromJson(Map<String, dynamic> json) {
    return PageSettings(
      gapX: (json['gapX'] as num? ?? 4).toDouble(),
      gapY: (json['gapY'] as num? ?? 6).toDouble(),
      marginX: (json['marginX'] as num? ?? 14).toDouble(),
      marginY: (json['marginY'] as num? ?? 12).toDouble(),
      format: json['format'] ?? 'a4',
      locale: json['locale'] ?? 'en-US',
      hideIcons: json['hideIcons'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'gapX': gapX,
    'gapY': gapY,
    'marginX': marginX,
    'marginY': marginY,
    'format': format,
    'locale': locale,
    'hideIcons': hideIcons,
  };

  factory PageSettings.empty() => PageSettings(
    gapX: 4,
    gapY: 6,
    marginX: 14,
    marginY: 12,
    format: 'a4',
    locale: 'en-US',
    hideIcons: false,
  );

  PageSettings copyWith({
    double? gapX,
    double? gapY,
    double? marginX,
    double? marginY,
    String? format,
    String? locale,
    bool? hideIcons,
  }) {
    return PageSettings(
      gapX: gapX ?? this.gapX,
      gapY: gapY ?? this.gapY,
      marginX: marginX ?? this.marginX,
      marginY: marginY ?? this.marginY,
      format: format ?? this.format,
      locale: locale ?? this.locale,
      hideIcons: hideIcons ?? this.hideIcons,
    );
  }
}

class Design {
  final LevelDesign level;
  final ColorDesign colors;

  Design({required this.level, required this.colors});

  factory Design.fromJson(Map<String, dynamic> json) {
    return Design(
      level: LevelDesign.fromJson(json['level'] ?? {}),
      colors: ColorDesign.fromJson(json['colors'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'level': level.toJson(),
    'colors': colors.toJson(),
  };

  factory Design.empty() =>
      Design(level: LevelDesign.empty(), colors: ColorDesign.empty());

  Design copyWith({LevelDesign? level, ColorDesign? colors}) {
    return Design(level: level ?? this.level, colors: colors ?? this.colors);
  }
}

class ColorDesign {
  final String primary;
  final String text;
  final String background;

  ColorDesign({
    required this.primary,
    required this.text,
    required this.background,
  });

  factory ColorDesign.fromJson(Map<String, dynamic> json) {
    return ColorDesign(
      primary: json['primary'] ?? '#28305c',
      text: json['text'] ?? 'rgba(0, 0, 0, 1)',
      background: json['background'] ?? 'rgba(255, 255, 255, 1)',
    );
  }

  Map<String, dynamic> toJson() => {
    'primary': primary,
    'text': text,
    'background': background,
  };

  factory ColorDesign.empty() => ColorDesign(
    primary: '#28305c',
    text: 'rgba(0, 0, 0, 1)',
    background: 'rgba(255, 255, 255, 1)',
  );

  ColorDesign copyWith({String? primary, String? text, String? background}) {
    return ColorDesign(
      primary: primary ?? this.primary,
      text: text ?? this.text,
      background: background ?? this.background,
    );
  }
}

class LevelDesign {
  final String icon;
  final String type;

  LevelDesign({required this.icon, required this.type});

  factory LevelDesign.fromJson(Map<String, dynamic> json) {
    return LevelDesign(
      icon: json['icon'] ?? 'star',
      type: json['type'] ?? 'circle',
    );
  }

  Map<String, dynamic> toJson() => {'icon': icon, 'type': type};

  factory LevelDesign.empty() => LevelDesign(icon: 'star', type: 'circle');

  LevelDesign copyWith({String? icon, String? type}) {
    return LevelDesign(icon: icon ?? this.icon, type: type ?? this.type);
  }
}

class Layout {
  final double sidebarWidth;
  final List<PageLayout> pages;

  Layout({required this.sidebarWidth, required this.pages});

  factory Layout.fromJson(Map<String, dynamic> json) {
    return Layout(
      sidebarWidth: (json['sidebarWidth'] as num? ?? 35).toDouble(),
      pages: (json['pages'] as List? ?? [])
          .map((e) => PageLayout.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sidebarWidth': sidebarWidth,
    'pages': pages.map((e) => e.toJson()).toList(),
  };

  factory Layout.empty() =>
      Layout(sidebarWidth: 35, pages: [PageLayout.empty()]);

  Layout copyWith({double? sidebarWidth, List<PageLayout>? pages}) {
    return Layout(
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      pages: pages ?? this.pages,
    );
  }
}

class PageLayout {
  final bool fullWidth;
  final List<String> main;
  final List<String> sidebar;

  PageLayout({
    required this.fullWidth,
    required this.main,
    required this.sidebar,
  });

  factory PageLayout.fromJson(Map<String, dynamic> json) {
    return PageLayout(
      fullWidth: json['fullWidth'] ?? false,
      main: List<String>.from(json['main'] ?? []),
      sidebar: List<String>.from(json['sidebar'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'fullWidth': fullWidth,
    'main': main,
    'sidebar': sidebar,
  };

  PageLayout copyWith({
    bool? fullWidth,
    List<String>? main,
    List<String>? sidebar,
  }) {
    return PageLayout(
      fullWidth: fullWidth ?? this.fullWidth,
      main: main ?? this.main,
      sidebar: sidebar ?? this.sidebar,
    );
  }

  factory PageLayout.empty() => PageLayout(
    fullWidth: false,
    main: [
      'profiles',
      'summary',
      'education',
      'experience',
      'projects',
      'volunteer',
      'references',
    ],
    sidebar: [
      'skills',
      'certifications',
      'awards',
      'languages',
      'interests',
      'publications',
    ],
  );
}

class Typography {
  final TypographyItem body;
  final TypographyItem heading;

  Typography({required this.body, required this.heading});

  factory Typography.fromJson(Map<String, dynamic> json) {
    return Typography(
      body: TypographyItem.fromJson(json['body'] ?? {}),
      heading: TypographyItem.fromJson(json['heading'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'body': body.toJson(),
    'heading': heading.toJson(),
  };

  factory Typography.empty() => Typography(
    body: TypographyItem.empty(fontSize: 10),
    heading: TypographyItem.empty(fontSize: 14),
  );

  Typography copyWith({TypographyItem? body, TypographyItem? heading}) {
    return Typography(
      body: body ?? this.body,
      heading: heading ?? this.heading,
    );
  }
}

class TypographyItem {
  final String fontFamily;
  final List<String> fontWeights;
  final double fontSize;
  final double lineHeight;

  TypographyItem({
    required this.fontFamily,
    required this.fontWeights,
    required this.fontSize,
    required this.lineHeight,
  });

  factory TypographyItem.fromJson(Map<String, dynamic> json) {
    return TypographyItem(
      fontFamily: json['fontFamily'] ?? 'IBM Plex Serif',
      fontWeights: List<String>.from(json['fontWeights'] ?? ['400']),
      fontSize: (json['fontSize'] as num? ?? 11).toDouble(),
      lineHeight: (json['lineHeight'] as num? ?? 1.5).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'fontWeights': fontWeights,
    'fontSize': fontSize,
    'lineHeight': lineHeight,
  };

  factory TypographyItem.empty({required double fontSize}) => TypographyItem(
    fontFamily: 'IBM Plex Serif',
    fontWeights: ['400'],
    fontSize: fontSize,
    lineHeight: 1.5,
  );

  TypographyItem copyWith({
    String? fontFamily,
    List<String>? fontWeights,
    double? fontSize,
    double? lineHeight,
  }) {
    return TypographyItem(
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeights: fontWeights ?? this.fontWeights,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}
