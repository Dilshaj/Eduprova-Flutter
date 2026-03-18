import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessagesRepository {
  final Dio _client = ApiClient.instance;

  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int limit = 20,
    String filter = 'all',
  }) async {
    try {
      final response = await _client.get(
        '/conversations',
        queryParameters: {'page': page, 'limit': limit, 'filter': filter},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List data = [];
        if (responseData is Map) {
          data = responseData['conversations'] ?? [];
        } else if (responseData is List) {
          data = responseData;
        }
        return [for (final item in data) ConversationModel.fromJson(item)];
      }
      return [];
    } catch (e, s) {
      debugPrint('Error getting conversations: $e\n$s');
      return [];
    }
  }

  Future<List<MessageModel>> getMessages(
    String conversationId, {
    String? cursor,
    int limit = 30,
  }) async {
    try {
      final response = await _client.get(
        '/messages/$conversationId',
        queryParameters: {'cursor': ?cursor, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List data = [];
        if (responseData is Map) {
          data = responseData['messages'] ?? [];
        } else if (responseData is List) {
          data = responseData;
        }
        return [for (final item in data) MessageModel.fromJson(item)];
      }
      return [];
    } catch (e, s) {
      debugPrint('Error getting messages: $e\n$s');
      return [];
    }
  }

  Future<MessageModel?> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? replyTo,
  }) async {
    try {
      final response = await _client.post(
        '/messages',
        data: {
          'conversationId': conversationId,
          'content': content,
          'type': type.toJson(),
          'replyTo': ?replyTo,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return MessageModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _client.patch('/conversations/$conversationId/read');
    } catch (e) {
      // Ignore error for now
    }
  }

  Future<void> addReaction(String messageId, String emoji) async {
    try {
      await _client.post(
        '/messages/$messageId/reactions',
        data: {'emoji': emoji},
      );
    } catch (e) {
      debugPrint('Error adding reaction: $e');
    }
  }

  Future<void> removeReaction(String messageId, String emoji) async {
    try {
      await _client.delete(
        '/messages/$messageId/reactions',
        data: {'emoji': emoji},
      );
    } catch (e) {
      debugPrint('Error removing reaction: $e');
    }
  }

  Future<ConversationModel?> createConversation(
    List<String> userIds, {
    String? name,
    String? avatar,
  }) async {
    try {
      final response = await _client.post(
        '/conversations',
        data: {
          'participants': userIds,
          'type': userIds.length > 1 ? 'group' : 'direct',
          'name': ?name,
          'avatar': ?avatar,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ConversationModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
