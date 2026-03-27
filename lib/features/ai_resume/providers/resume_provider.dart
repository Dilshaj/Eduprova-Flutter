import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resume_data.dart';
import '../data/resume_repository.dart';
import 'resume_list_provider.dart';

final resumeProvider = NotifierProvider<ResumeNotifier, ResumeData>(
  ResumeNotifier.new,
);

class ResumeNotifier extends Notifier<ResumeData> {
  String? _currentResumeId;
  Timer? _saveTimer;
  late ResumeRepository _repository;

  String? get currentResumeId => _currentResumeId;

  @override
  ResumeData build() {
    _repository = ref.watch(resumeRepositoryProvider);
    return ResumeData.empty();
  }

  Future<void> loadResume(String id) async {
    _currentResumeId = id;
    try {
      final jsonResponse = await _repository.getResume(id);
      if (jsonResponse['data'] != null) {
        state = ResumeData.fromJson(jsonResponse['data']);
      } else {
        state = ResumeData.empty();
      }
    } catch (e) {
      state = ResumeData.empty();
    }
  }

  void _setState(ResumeData newState) {
    state = newState;
    if (_currentResumeId == null) return;

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () async {
      try {
        await _repository.updateResume(_currentResumeId!, data: state);
      } catch (e) {
        // Handle auto-save error quietly
      }
    });
  }

  void updateBasics(Basics newBasics) {
    _setState(state.copyWith(basics: newBasics));
  }

  void setResumeData(ResumeData newData) {
    _setState(newData);
  }

  void updatePicture(Picture newPicture) {
    _setState(state.copyWith(picture: newPicture));
  }

  void updateMetadata(Metadata newMetadata) {
    _setState(state.copyWith(metadata: newMetadata));
  }

  void updateTypography(Typography newTypography) {
    _setState(
      state.copyWith(
        metadata: state.metadata.copyWith(typography: newTypography),
      ),
    );
  }

  void updateTheme(ColorDesign newTheme) {
    _setState(
      state.copyWith(
        metadata: state.metadata.copyWith(
          design: state.metadata.design.copyWith(colors: newTheme),
        ),
      ),
    );
  }

  void updateSkillLevelStyle(String style) {
    _setState(
      state.copyWith(
        metadata: state.metadata.copyWith(
          design: state.metadata.design.copyWith(
            level: state.metadata.design.level.copyWith(type: style),
          ),
        ),
      ),
    );
  }

  void updateSummary(Summary newSummary) {
    _setState(
      ResumeData(
        picture: state.picture,
        basics: state.basics,
        summary: newSummary,
        sections: state.sections,
        customSections: state.customSections,
        metadata: state.metadata,
      ),
    );
  }

  void updateSection<T extends ResumeItem>(
    String sectionKey,
    Section<T> newSection,
  ) {
    final sections = state.sections;
    final newSections = _updateSectionByKey(sections, sectionKey, newSection);

    _setState(
      ResumeData(
        picture: state.picture,
        basics: state.basics,
        summary: state.summary,
        sections: newSections,
        customSections: state.customSections,
        metadata: state.metadata,
      ),
    );
  }

  Sections _updateSectionByKey(
    Sections sections,
    String key,
    Section<dynamic> newSection,
  ) {
    switch (key) {
      case 'profiles':
        return sections.copyWith(
          profiles: Section<ProfileItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<ProfileItem>.from(newSection.items),
          ),
        );
      case 'experience':
        return sections.copyWith(
          experience: Section<ExperienceItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<ExperienceItem>.from(newSection.items),
          ),
        );
      case 'education':
        return sections.copyWith(
          education: Section<EducationItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<EducationItem>.from(newSection.items),
          ),
        );
      case 'projects':
        return sections.copyWith(
          projects: Section<ProjectItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<ProjectItem>.from(newSection.items),
          ),
        );
      case 'skills':
        return sections.copyWith(
          skills: Section<SkillItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<SkillItem>.from(newSection.items),
          ),
        );
      case 'languages':
        return sections.copyWith(
          languages: Section<LanguageItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<LanguageItem>.from(newSection.items),
          ),
        );
      case 'certifications':
        return sections.copyWith(
          certifications: Section<CertificationItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<CertificationItem>.from(newSection.items),
          ),
        );
      case 'awards':
        return sections.copyWith(
          awards: Section<AwardItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<AwardItem>.from(newSection.items),
          ),
        );
      case 'interests':
        return sections.copyWith(
          interests: Section<InterestItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<InterestItem>.from(newSection.items),
          ),
        );
      case 'publications':
        return sections.copyWith(
          publications: Section<PublicationItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<PublicationItem>.from(newSection.items),
          ),
        );
      case 'volunteer':
        return sections.copyWith(
          volunteer: Section<VolunteerItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<VolunteerItem>.from(newSection.items),
          ),
        );
      case 'references':
        return sections.copyWith(
          references: Section<ReferenceItem>(
            title: newSection.title,
            columns: newSection.columns,
            hidden: newSection.hidden,
            items: List<ReferenceItem>.from(newSection.items),
          ),
        );
      default:
        return sections;
    }
  }

  void addItem<T extends ResumeItem>(String sectionKey, T item) {
    final sections = state.sections;
    final section = _getSectionByKey(sections, sectionKey);
    final newItems = List<T>.from(section.items)..add(item);
    final newSection = Section<T>(
      title: section.title,
      columns: section.columns,
      hidden: section.hidden,
      items: newItems,
    );
    updateSection(sectionKey, newSection);
  }

  void removeItem<T extends ResumeItem>(String sectionKey, String itemId) {
    final sections = state.sections;
    final section = _getSectionByKey(sections, sectionKey);
    final newItems = section.items.where((i) => i.id != itemId).toList();
    final newSection = Section<T>(
      title: section.title,
      columns: section.columns,
      hidden: section.hidden,
      items: List<T>.from(newItems),
    );
    updateSection(sectionKey, newSection);
  }

  void updateItem<T extends ResumeItem>(String sectionKey, T item) {
    final sections = state.sections;
    final section = _getSectionByKey(sections, sectionKey);
    final newItems = section.items
        .map((i) => i.id == item.id ? item : i)
        .toList();
    final newSection = Section<T>(
      title: section.title,
      columns: section.columns,
      hidden: section.hidden,
      items: List<T>.from(newItems),
    );
    updateSection(sectionKey, newSection);
  }

  void reorderItem<T extends ResumeItem>(
    String sectionKey,
    int oldIndex,
    int newIndex,
  ) {
    final sections = state.sections;
    final section = _getSectionByKey(sections, sectionKey);
    final items = List<T>.from(section.items);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    final newSection = Section<T>(
      title: section.title,
      columns: section.columns,
      hidden: section.hidden,
      items: items,
    );
    updateSection(sectionKey, newSection);
  }

  Section<dynamic> _getSectionByKey(Sections sections, String key) {
    return switch (key) {
      'profiles' => sections.profiles,
      'experience' => sections.experience,
      'education' => sections.education,
      'projects' => sections.projects,
      'skills' => sections.skills,
      'languages' => sections.languages,
      'certifications' => sections.certifications,
      'awards' => sections.awards,
      'interests' => sections.interests,
      'publications' => sections.publications,
      'volunteer' => sections.volunteer,
      'references' => sections.references,
      _ => throw UnimplementedError('Section $key not found'),
    };
  }
}
