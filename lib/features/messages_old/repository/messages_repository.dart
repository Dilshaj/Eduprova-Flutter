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
    String? order,
  }) async {
    try {
      final response = await _client.get(
        '/messages/$conversationId',
        queryParameters: {'cursor': ?cursor, 'limit': limit, 'order': ?order},
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
          'participantIds': userIds,
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

  Future<ConversationModel?> getConversationById(String id) async {
    try {
      final response = await _client.get('/conversations/$id');
      if (response.statusCode == 200) {
        return ConversationModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }
    } catch (e) {
      debugPrint('Error fetching conversation: $e');
    }
    return null;
  }

  Future<ConversationModel?> addParticipants(
    String conversationId,
    List<String> userIds,
  ) async {
    try {
      final response = await _client.patch(
        '/conversations/$conversationId/participants',
        data: {'userIds': userIds},
      );
      if (response.statusCode == 200) {
        return ConversationModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }
    } catch (e) {
      debugPrint('Error adding participants: $e');
    }
    return null;
  }

  Future<ConversationModel?> updateConversation(
    String conversationId, {
    String? name,
    String? avatar,
    String? description,
  }) async {
    try {
      final response = await _client.patch(
        '/conversations/$conversationId',
        data: {
          'name': ?name,
          'avatar': ?avatar,
          'description': ?description,
        },
      );
      if (response.statusCode == 200) {
        return ConversationModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }
    } catch (e) {
      debugPrint('Error updating conversation: $e');
    }
    return null;
  }

  Future<ConversationModel?> acceptInvite(String id) async {
    try {
      final response = await _client.patch('/conversations/$id/accept');
      if (response.statusCode == 200) {
        return ConversationModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }
    } catch (e) {
      debugPrint('Error accepting invite: $e');
    }
    return null;
  }

  Future<bool> rejectInvite(String id) async {
    try {
      final response = await _client.patch('/conversations/$id/reject');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error rejecting invite: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> uploadChatFile({
    required String chatId,
    required String filePath,
    String? messageId,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'chatId': chatId,
        'messageId': ?messageId,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _client.post(
        '/upload/chat',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading chat file: $e');
      return null;
    }
  }
}
