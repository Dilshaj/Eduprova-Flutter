import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/features/home/storie/view_storie/stories_provider.dart';

class StoryRepository {
  Future<List<StatusProfile>> getFeed() async {
    try {
      final response = await ApiClient.instance.get('/stories/feed');
      final data = response.data;
      
      if (data is Map && data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to fetch stories');
      }

      final List feedList = (data is Map) ? (data['data'] ?? data['stories'] ?? []) : (data as List);

      return [
        for (var item in feedList)
          StatusProfile(
            id: item['_id']?.toString() ?? item['userId']?['_id']?.toString() ?? '',
            name: item['userName'] ?? '${item['userId']?['firstName'] ?? ''} ${item['userId']?['lastName'] ?? ''}'.trim(),
            profileUrl: (item['userAvatar'] ?? item['userId']?['avatar'] ?? '').toString().isNotEmpty 
                ? (item['userAvatar'] ?? item['userId']?['avatar']).toString()
                : 'https://ui-avatars.com/api/?name=${item['userName'] ?? 'User'}&background=random',
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
      debugPrint('Error fetching stories: $e');
      rethrow;
    }
  }

  Future<void> createStory(List<dynamic> mediaItems, {bool isCollage = false}) async {
    try {
      final formData = FormData();
      
      for (var item in mediaItems) {
        if (item is Uint8List) {
          formData.files.add(MapEntry(
            'media',
            MultipartFile.fromBytes(
              item,
              filename: 'story.png',
              contentType: MediaType('image', 'png'),
            ),
          ));
        } else if (item is String) {
          formData.files.add(MapEntry(
            'media',
            await MultipartFile.fromFile(
              item,
              contentType: item.toLowerCase().endsWith('.mp4') 
                  ? MediaType('video', 'mp4') 
                  : MediaType('image', 'jpeg'),
            ),
          ));
        }
      }
      
      formData.fields.addAll([
        MapEntry('isCollage', isCollage.toString()),
        const MapEntry('mediaType', 'image'),
      ]);

      await ApiClient.instance.post('/stories', data: formData);
    } on DioException catch (e) {
      final message = e.response?.data is Map ? (e.response?.data['message'] ?? e.response?.data['error']) : e.message;
      debugPrint('Dio error creating story: $message');
      throw Exception(message ?? 'Failed to upload story');
    } catch (e) {
      debugPrint('Error creating story: $e');
      rethrow;
    }
  }
}
