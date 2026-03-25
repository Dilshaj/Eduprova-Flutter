import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/features/home/storie/view_storie/stories_provider.dart';

class StoryRepository {
  Future<List<StatusProfile>> getFeed() async {
    try {
      final response = await ApiClient.instance.get('/stories/feed');
      final data = response.data;
      
      final List feedList = (data is Map) ? (data['data'] ?? []) : (data as List);

      return [
        for (var item in feedList)
          StatusProfile(
            id: item['_id']?.toString() ?? item['userId']?['_id']?.toString() ?? '',
            name: item['userName'] ?? '${item['userId']?['firstName'] ?? ''} ${item['userId']?['lastName'] ?? ''}'.trim(),
            profileUrl: item['userAvatar'] ?? item['userId']?['avatar'] ?? 'https://picsum.photos/seed/default/50/50',
            hasUnseen: item['hasUnseen'] ?? false,
            statuses: [
              for (var story in (item['stories'] as List? ?? []))
                StatusItem(
                  url: story['mediaUrl'] ?? '',
                  type: story['mediaType'] == 'video' ? .video : .image,
                ),
            ],
          ),
      ];
    } catch (e) {
      debugPrint('Error fetching stories: $e');
      rethrow;
    }
  }

  Future<void> createStory(List<String> filePaths, {bool isCollage = false}) async {
    try {
      final formData = FormData();
      
      for (var path in filePaths) {
        formData.files.add(MapEntry(
          'media',
          await MultipartFile.fromFile(path),
        ));
      }
      
      formData.fields.add(MapEntry('isCollage', isCollage.toString()));

      await ApiClient.instance.post('/stories', data: formData);
    } catch (e) {
      debugPrint('Error creating story: $e');
      rethrow;
    }
  }
}
