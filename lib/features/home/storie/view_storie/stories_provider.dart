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
}
