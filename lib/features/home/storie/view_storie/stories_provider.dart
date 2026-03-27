import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'story_repository.dart';

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
  final bool hasUnseen;

  const StatusProfile({
    required this.id,
    required this.name,
    required this.profileUrl,
    required this.statuses,
    this.hasUnseen = false,
  });
}

final storyRepositoryProvider = Provider<StoryRepository>((ref) => .new());

final statusProfilesProvider =
    NotifierProvider<StoriesNotifier, AsyncValue<List<StatusProfile>>>(
      StoriesNotifier.new,
    );

class StoriesNotifier extends Notifier<AsyncValue<List<StatusProfile>>> {
  @override
  AsyncValue<List<StatusProfile>> build() {
    _fetchStories();
    return const .loading();
  }

  Future<void> _fetchStories() async {
    state = const .loading();
    try {
      final stories = await ref.read(storyRepositoryProvider).getFeed();
      state = .data(stories);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    await _fetchStories();
  }

  Future<void> createStory(List<dynamic> mediaItems, {bool isCollage = false}) async {
    try {
      await ref.read(storyRepositoryProvider).createStory(mediaItems, isCollage: isCollage);
      await refresh();
    } catch (e) {
      debugPrint('Error in notifier creating story: $e');
      rethrow;
    }
  }
}

List<StatusProfile> getGreetingDummyStories() {
  return [
    StatusProfile(
      id: '1',
      name: 'Design',
      profileUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=400&h=600&fit=crop',
      hasUnseen: true,
      statuses: [
        const StatusItem(url: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f', type: StatusType.image),
        const StatusItem(url: 'https://images.unsplash.com/photo-1558655146-d09347e92766', type: StatusType.image),
      ],
    ),
    StatusProfile(
      id: '2',
      name: 'Code',
      profileUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&h=600&fit=crop',
      hasUnseen: true,
      statuses: [
        const StatusItem(url: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085', type: StatusType.image),
      ],
    ),
    StatusProfile(
      id: '3',
      name: 'Lifestyle',
      profileUrl: 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=400&h=600&fit=crop',
      hasUnseen: false,
      statuses: [
        const StatusItem(url: 'https://images.unsplash.com/photo-1511367461989-f85a21fda167', type: StatusType.image),
      ],
    ),
    StatusProfile(
      id: '4',
      name: 'Ideas',
      profileUrl: 'https://images.unsplash.com/photo-1456324504439-367cee3b3c32?w=400&h=600&fit=crop',
      hasUnseen: false,
      statuses: [
        const StatusItem(url: 'https://images.unsplash.com/photo-1456324504439-367cee3b3c32', type: StatusType.image),
      ],
    ),
    StatusProfile(
      id: '5',
      name: 'EduProva',
      profileUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400&h=600&fit=crop',
      hasUnseen: true,
      statuses: [
        const StatusItem(url: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f', type: StatusType.image),
        const StatusItem(url: 'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e', type: StatusType.image),
        const StatusItem(url: 'https://images.unsplash.com/photo-1523240715637-8a3635196fe0', type: StatusType.image),
      ],
    ),
  ];
}
