import '../../auth/models/user_model.dart';

enum MeetingStatus { scheduled, ongoing, completed, cancelled }

MeetingStatus meetingStatusFromString(String? value) => switch (value) {
  'ongoing' => MeetingStatus.ongoing,
  'completed' => MeetingStatus.completed,
  'cancelled' => MeetingStatus.cancelled,
  _ => MeetingStatus.scheduled,
};

class MeetingModel {
  final String id;
  final String title;
  final String? description;
  final UserModel? host;
  final List<UserModel> participants;
  final DateTime startTime;
  final DateTime endTime;
  final String roomId;
  final String meetingLink;
  final MeetingStatus status;
  final DateTime createdAt;

  const MeetingModel({
    required this.id,
    required this.title,
    this.description,
    this.host,
    this.participants = const [],
    required this.startTime,
    required this.endTime,
    required this.roomId,
    required this.meetingLink,
    required this.status,
    required this.createdAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    final hostData = json['hostId'];
    final participantsRaw = json['participants'] as List? ?? const [];

    return MeetingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled meeting',
      description: json['description']?.toString(),
      host: hostData is Map<String, dynamic>
          ? UserModel.fromJson(hostData)
          : null,
      participants: [
        for (final item in participantsRaw)
          if (item is Map<String, dynamic>) UserModel.fromJson(item),
      ],
      startTime:
          DateTime.tryParse(json['startTime']?.toString() ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(json['endTime']?.toString() ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      roomId: json['roomId']?.toString() ?? '',
      meetingLink: json['meetingLink']?.toString() ?? '',
      status: meetingStatusFromString(json['status']?.toString()),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String get roomName => 'meeting:$roomId';
}
