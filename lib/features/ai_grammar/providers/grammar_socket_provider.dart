import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/features/ai_grammar/providers/grammar_audio_player_provider.dart';
import 'package:eduprova/features/ai_grammar/repositories/grammar_repository.dart';

class CorrectionResult {
  final String original;
  final String corrected;
  final String? refinedText;
  final String? explanation;
  final String? audio;
  final int? scoreImprovement;
  final Map<String, dynamic>? metrics;
  final List<dynamic>? keyImprovements;
  final List<dynamic>? highlights;

  CorrectionResult({
    required this.original,
    required this.corrected,
    this.refinedText,
    this.explanation,
    this.audio,
    this.scoreImprovement,
    this.metrics,
    this.keyImprovements,
    this.highlights,
  });

  factory CorrectionResult.fromJson(Map<String, dynamic> json) {
    return CorrectionResult(
      original: json['original'] as String? ?? '',
      corrected:
          json['corrected'] as String? ?? json['refinedText'] as String? ?? '',
      refinedText: json['refinedText'] as String?,
      explanation: json['explanation'] as String?,
      audio: json['audio'] as String?,
      scoreImprovement: json['scoreImprovement'] as int?,
      metrics: json['metrics'] as Map<String, dynamic>?,
      keyImprovements: json['keyImprovements'] as List<dynamic>?,
      highlights: json['highlights'] as List<dynamic>?,
    );
  }
}

class GrammarMessage {
  final String role;
  final String text;
  final bool isFinal;
  final Map<String, dynamic>? feedback;
  final String? audio;

  GrammarMessage({
    required this.role,
    required this.text,
    this.isFinal = true,
    this.feedback,
    this.audio,
  });

  GrammarMessage copyWith({
    String? role,
    String? text,
    bool? isFinal,
    Map<String, dynamic>? feedback,
    String? audio,
  }) {
    return GrammarMessage(
      role: role ?? this.role,
      text: text ?? this.text,
      isFinal: isFinal ?? this.isFinal,
      feedback: feedback ?? this.feedback,
      audio: audio ?? this.audio,
    );
  }
}

class GrammarSocketState {
  final List<GrammarMessage> messages;
  final bool isConnected;
  final bool isAiSpeaking;
  final Map<String, dynamic>? lastFeedback;
  final Map<String, dynamic>? lastScores;
  final String? transcript;
  final CorrectionResult? correctionResult;
  final bool isRefining;

  GrammarSocketState({
    this.messages = const [],
    this.isConnected = false,
    this.isAiSpeaking = false,
    this.lastFeedback,
    this.lastScores,
    this.transcript,
    this.correctionResult,
    this.isRefining = false,
  });

  GrammarSocketState copyWith({
    List<GrammarMessage>? messages,
    bool? isConnected,
    bool? isAiSpeaking,
    Map<String, dynamic>? lastFeedback,
    Map<String, dynamic>? lastScores,
    String? transcript,
    CorrectionResult? correctionResult,
    bool? isRefining,
  }) {
    return GrammarSocketState(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      isAiSpeaking: isAiSpeaking ?? this.isAiSpeaking,
      lastFeedback: lastFeedback ?? this.lastFeedback,
      lastScores: lastScores ?? this.lastScores,
      transcript: transcript ?? this.transcript,
      correctionResult: correctionResult ?? this.correctionResult,
      isRefining: isRefining ?? this.isRefining,
    );
  }
}

class GrammarSocketNotifier extends Notifier<GrammarSocketState> {
  io.Socket? _socket;
  String? _currentAiMessage;
  String? _currentSessionId;

  @override
  GrammarSocketState build() {
    ref.onDispose(() {
      _socket?.disconnect();
      _socket?.dispose();
    });
    return GrammarSocketState();
  }

  void joinPractice(String mode) async {
    // Session tracking to avoid race conditions
    _currentSessionId = DateTime.now().toIso8601String();
    final sessionId = _currentSessionId;

    // Disconnect existing socket if it exists
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    // Reset state for new practice
    state = GrammarSocketState();
    _currentAiMessage = null;

    // Stop ongoing audio
    ref.read(grammarAudioPlayerProvider.notifier).stop();

    if (mode == 'conversation') {
      refreshConversationQuestion(sessionId: sessionId);
    }

    final baseUrl = ApiClient.baseUrl;
    final socketUrl = '$baseUrl/communication';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    _socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
      'extraHeaders': {if (token != null) 'Authorization': 'Bearer $token'},
    });

    _socket!.onConnect((_) {
      state = state.copyWith(isConnected: true);
      _socket!.emit('join_practice', {'mode': mode});
    });

    _socket!.onDisconnect((_) {
      state = state.copyWith(isConnected: false);
    });

    _socket!.on('ai_text_chunk', (data) {
      final chunk = data['text'] as String;
      final isFirst = data['isFirst'] as bool;

      if (isFirst) {
        _currentAiMessage = chunk;
        final newMessage = GrammarMessage(
          role: 'ai',
          text: _currentAiMessage!,
          isFinal: false,
        );
        state = state.copyWith(
          messages: [...state.messages, newMessage],
          isAiSpeaking: true,
        );
      } else {
        _currentAiMessage = (_currentAiMessage ?? '') + chunk;
        final messages = List<GrammarMessage>.from(state.messages);
        if (messages.isNotEmpty && messages.last.role == 'ai') {
          messages[messages.length - 1] = messages.last.copyWith(
            text: _currentAiMessage,
          );
          state = state.copyWith(messages: messages);
        }
      }
    });

    _socket!.on('ai_response_complete', (_) {
      final messages = List<GrammarMessage>.from(state.messages);
      if (messages.isNotEmpty && messages.last.role == 'ai') {
        messages[messages.length - 1] = messages.last.copyWith(isFinal: true);
        state = state.copyWith(messages: messages, isAiSpeaking: false);
      }
      _currentAiMessage = null;
    });

    _socket!.on('ai_audio_chunk', (data) {
      final base64Audio = data['audio'] as String;
      ref.read(grammarAudioPlayerProvider.notifier).addChunk(base64Audio);
    });

    _socket!.on('roleplay_feedback', (data) {
      final messages = List<GrammarMessage>.from(state.messages);
      // Find the last user message to attach feedback
      for (int i = messages.length - 1; i >= 0; i--) {
        if (messages[i].role == 'user') {
          messages[i] = messages[i].copyWith(feedback: data);
          state = state.copyWith(messages: messages, lastFeedback: data);
          break;
        }
      }
    });

    _socket!.on('roleplay_scores', (data) {
      state = state.copyWith(lastScores: data);
    });

    _socket!.on('transcript', (data) {
      final text = data['text'] as String;
      state = state.copyWith(transcript: text);
    });

    _socket!.on('correction_result', (data) {
      final result = CorrectionResult.fromJson(data);
      state = state.copyWith(correctionResult: result, isRefining: false);
      if (result.audio != null) {
        ref.read(grammarAudioPlayerProvider.notifier).playBase64(result.audio!);
      }
    });

    _socket!.on('error', (data) {
      state = state.copyWith(isRefining: false);
    });

    _socket!.connect();
  }

  void startRoleplay({
    required String roleType,
    String? difficulty,
    String? experienceLevel,
    String? companyType,
    String? jobTitle,
    List<String>? techStack,
    String? seniorityLevel,
    String? customPrompt,
  }) {
    if (_socket == null) {
      joinPractice('roleplay');
    }

    final data = {
      'roleType': roleType,
      'difficulty': ?difficulty,
      'experienceLevel': ?experienceLevel,
      'companyType': ?companyType,
      'jobTitle': ?jobTitle,
      'techStack': ?techStack,
      'seniorityLevel': ?seniorityLevel,
      'customPrompt': ?customPrompt,
    };

    if (_socket != null && _socket!.connected) {
      state = GrammarSocketState(); // Start fresh roleplay session
      _currentAiMessage = null;
      _socket!.emit('start_roleplay', data);
    } else {
      _socket?.onConnect((_) {
        _socket!.emit('join_practice', {'mode': 'roleplay'});
        _socket!.emit('start_roleplay', data);
      });
      _socket!.connect();
    }
  }

  void sendUserText(String text) {
    _socket?.emit('roleplay_user_message', {'text': text});
    final userMsg = GrammarMessage(role: 'user', text: text);
    state = state.copyWith(messages: [...state.messages, userMsg]);
  }

  void correctSentence(String text, String userId, {String? tone}) {
    state = state.copyWith(isRefining: true, correctionResult: null);
    _socket?.emit('sentence_correct', {
      'text': text,
      'userId': userId,
      'tone': tone,
    });
  }

  Future<void> refreshConversationQuestion({String? sessionId}) async {
    final activeSessionId = sessionId ?? _currentSessionId;
    try {
      final repo = ref.read(grammarRepositoryProvider);
      final question = await repo.fetchPracticeQuestion('conversation');

      if (activeSessionId != _currentSessionId) return;

      final aiMessage = GrammarMessage(
        role: 'ai',
        text: question.question,
        audio: question.audio,
      );

      state = state.copyWith(
        messages: [aiMessage],
        lastFeedback: null,
        transcript: '',
        lastScores: null,
      );

      if (question.audio != null) {
        ref
            .read(grammarAudioPlayerProvider.notifier)
            .playBase64(question.audio!);
      }
    } catch (e) {
      debugPrint('Error loading conversation question: $e');
      if (activeSessionId != _currentSessionId) return;
      final errorMessage = GrammarMessage(
        role: 'ai',
        text: "Sorry, I couldn't load the practice question. Please try again.",
      );
      state = state.copyWith(messages: [errorMessage]);
    }
  }
}

final grammarSocketProvider =
    NotifierProvider<GrammarSocketNotifier, GrammarSocketState>(
      GrammarSocketNotifier.new,
    );

// Note: AudioChunksNotifier removed in favor of GrammarAudioPlayerNotifier
