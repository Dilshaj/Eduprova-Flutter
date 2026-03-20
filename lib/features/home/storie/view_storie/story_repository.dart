import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/features/home/storie/view_storie/stories_provider.dart';

class StoryRepository {
  Future<List<StatusProfile>> getFeed() async {
    try {
      final response = await ApiClient.instance.get('/stories/feed');
      final data = response.data as List;

      return [
        for (var item in data)
          StatusProfile(
            id: item['userId']?['_id'] ?? '',
            name: '${item['userId']?['firstName'] ?? ''} ${item['userId']?['lastName'] ?? ''}'.trim(),
            profileUrl: item['userId']?['avatar'] ?? 'https://picsum.photos/seed/default/50/50',
            hasUnseen: item['hasUnseen'] ?? false,
            statuses: [
              for (var story in (item['stories'] as List? ?? []))
                StatusItem(
                  url: story['mediaUrl'] ?? '',
                  type: story['mediaType'] == 'video' ? StatusType.video : StatusType.image,
                ),
            ],
          ),
      ];
    } catch (e) {
      rethrow;
    }
  }
}
