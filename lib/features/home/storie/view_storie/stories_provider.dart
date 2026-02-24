import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StatusType { image, video }

class StatusItem {
  final String url;
  final StatusType type;
  final Duration
  duration; // Custom duration for images, ignored/fallback for videos

  const StatusItem({
    required this.url,
    required this.type,
    this.duration = const Duration(seconds: 4),
  });
}

class StatusProfile {
  final String id;
  final String name;
  final String profileUrl;
  final List<StatusItem> statuses;

  const StatusProfile({
    required this.id,
    required this.name,
    required this.profileUrl,
    required this.statuses,
  });
}

final statusProfilesProvider = Provider<List<StatusProfile>>((ref) {
  return [
    StatusProfile(
      id: 'user_1',
      name: 'Maria',
      profileUrl: 'https://picsum.photos/seed/user1/50/50',
      statuses: [
        const StatusItem(
          url: 'https://picsum.photos/seed/1_1/800/1200',
          type: StatusType.image,
        ),
        const StatusItem(
          url:
              'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
          type: StatusType.video,
        ),
        const StatusItem(
          url: 'https://picsum.photos/seed/1_3/800/1200',
          type: StatusType.image,
        ),
      ],
    ),
    StatusProfile(
      id: 'user_2',
      name: 'John',
      profileUrl: 'https://picsum.photos/seed/user2/50/50',
      statuses: [
        const StatusItem(
          url: 'https://picsum.photos/seed/2_1/800/1200',
          type: StatusType.image,
        ),
        const StatusItem(
          url: 'https://picsum.photos/seed/2_2/800/1200',
          type: StatusType.image,
        ),
      ],
    ),
    StatusProfile(
      id: 'user_3',
      name: 'Anna',
      profileUrl: 'https://picsum.photos/seed/user3/50/50',
      statuses: [
        const StatusItem(
          url:
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          type: StatusType.video,
        ),
        const StatusItem(
          url: 'https://picsum.photos/seed/3_2/800/1200',
          type: StatusType.image,
        ),
      ],
    ),
  ];
});
