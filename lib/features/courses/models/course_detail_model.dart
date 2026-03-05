import '../../../core/network/api_client.dart';
import 'course_model.dart';

class CourseDetailModel extends CourseModel {
  final String? muxPlaybackId;
  final String? video;
  final String? storageType;
  final VideoSourceModel? videoSource;
  final List<ChapterModel> curriculum;
  final List<String> learningPoints;
  final List<String> requirements;

  CourseDetailModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.category,
    required super.level,
    required super.language,
    required super.description,
    required super.originalPrice,
    super.discountedPrice,
    super.thumbnail,
    required super.rating,
    required super.numReviews,
    required super.studentCount,
    super.duration,
    super.instructor,
    super.isOwner,
    this.video,
    this.muxPlaybackId,
    this.storageType,
    this.videoSource,
    this.curriculum = const [],
    this.learningPoints = const [],
    this.requirements = const [],
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    String? thumbnail = json['thumbnail'];
    if (thumbnail != null &&
        thumbnail.isNotEmpty &&
        !thumbnail.startsWith('http') &&
        !thumbnail.startsWith('data:')) {
      thumbnail = '${ApiClient.baseUrl}$thumbnail';
    }

    return CourseDetailModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      language: json['language'] ?? '',
      description: json['description'] ?? '',
      originalPrice: json['originalPrice'] ?? 0,
      discountedPrice: json['discountedPrice'],
      thumbnail: thumbnail,
      rating: json['rating'] ?? 0,
      numReviews: (json['numReviews'] as num?)?.toInt() ?? 0,
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
      duration: json['duration'],
      instructor: json['instructor'] != null
          ? InstructorModel.fromJson(json['instructor'])
          : null,
      isOwner: json['isOwner'] ?? false,
      video: json['video'],
      muxPlaybackId: json['muxPlaybackId'],
      storageType: json['storageType'],
      videoSource: json['videoSource'] != null
          ? VideoSourceModel.fromJson(json['videoSource'])
          : null,
      curriculum: json['curriculum'] != null
          ? (json['curriculum'] as List)
                .map((e) => ChapterModel.fromJson(e))
                .toList()
          : [],
      learningPoints: List<String>.from(json['learningPoints'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
    );
  }
}

class VideoSourceModel {
  final String type; // e.g., "mux"
  final String? playbackId;
  final String? token;
  final String? thumbnailUrl;

  VideoSourceModel({
    required this.type,
    this.playbackId,
    this.token,
    this.thumbnailUrl,
  });

  factory VideoSourceModel.fromJson(Map<String, dynamic> json) {
    return VideoSourceModel(
      type: json['type'] ?? '',
      playbackId: json['playbackId'],
      token: json['token'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

class ChapterModel {
  final String id;
  final String title;
  final String? duration;
  final bool hasExam;
  final List<LectureModel> lectures;

  ChapterModel({
    required this.id,
    required this.title,
    this.duration,
    this.hasExam = false,
    this.lectures = const [],
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'],
      hasExam: json['hasExam'] ?? false,
      lectures: json['lectures'] != null
          ? (json['lectures'] as List)
                .map((e) => LectureModel.fromJson(e))
                .toList()
          : [],
    );
  }
}

class LectureModel {
  final String id;
  final String title;
  final String description;
  final num duration; // Changed to num to handle potential doubles
  final String? video;
  final String? muxPlaybackId;
  final String? storageType;
  final String? status;
  final bool freePreview;
  final VideoSourceModel? videoSource;
  final List<AttachmentModel> attachments;

  LectureModel({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    this.video,
    this.muxPlaybackId,
    this.storageType,
    this.status,
    this.freePreview = false,
    this.videoSource,
    this.attachments = const [],
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      video: json['video'],
      muxPlaybackId: json['muxPlaybackId'],
      storageType: json['storageType'],
      status: json['status'],
      freePreview: json['freePreview'] ?? false,
      videoSource: json['videoSource'] != null
          ? VideoSourceModel.fromJson(json['videoSource'])
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
                .map((e) => AttachmentModel.fromJson(e))
                .toList()
          : [],
    );
  }
}

class AttachmentModel {
  final String id;
  final String title;
  final String url;
  final String type;
  final bool isDownloadable;

  AttachmentModel({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.isDownloadable = true,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      isDownloadable: json['isDownloadable'] ?? true,
    );
  }
}
