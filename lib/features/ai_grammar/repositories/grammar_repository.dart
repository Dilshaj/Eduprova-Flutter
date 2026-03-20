import 'package:eduprova/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GrammarPracticeQuestion {
  final String id;
  final String question;
  final String topic;
  final String difficulty;
  final String? audio;

  GrammarPracticeQuestion({
    required this.id,
    required this.question,
    required this.topic,
    required this.difficulty,
    this.audio,
  });

  factory GrammarPracticeQuestion.fromJson(Map<String, dynamic> json) {
    return GrammarPracticeQuestion(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      topic: json['topic']?.toString() ?? 'General',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      audio: json['audio']?.toString(),
    );
  }
}

class GrammarAnalysisResult {
  final int grammarScore;
  final int fluencyScore;
  final int vocabularyScore;
  final String improvedResponse;
  final String? transcription;
  final Map<String, dynamic> suggestions;

  GrammarAnalysisResult({
    required this.grammarScore,
    required this.fluencyScore,
    required this.vocabularyScore,
    required this.improvedResponse,
    this.transcription,
    required this.suggestions,
  });

  factory GrammarAnalysisResult.fromJson(Map<String, dynamic> json) {
    return GrammarAnalysisResult(
      grammarScore: (json['grammarScore'] as num?)?.toInt() ?? 0,
      fluencyScore: (json['fluencyScore'] as num?)?.toInt() ?? 0,
      vocabularyScore: (json['vocabularyScore'] as num?)?.toInt() ?? 0,
      improvedResponse: json['improvedResponse']?.toString() ?? '',
      transcription: json['transcription']?.toString(),
      suggestions: json['aiSuggestions'] as Map<String, dynamic>? ?? {},
    );
  }
}

class GrammarRepository {
  Future<GrammarPracticeQuestion> fetchPracticeQuestion(String topic) async {
    final response = await ApiClient.instance.get(
      '/ai/practice/question',
      // queryParameters: {'topic': topic},
    );
    return GrammarPracticeQuestion.fromJson(response.data);
  }

  Future<GrammarAnalysisResult> analyzePracticeResponse(
    String question,
    String answer, {
    String? audio,
  }) async {
    final response = await ApiClient.instance.post(
      '/ai/practice/analyze',
      data: {'question': question, 'answer': answer, 'audio': ?audio},
    );
    return GrammarAnalysisResult.fromJson(response.data);
  }
}

final grammarRepositoryProvider = Provider((ref) => GrammarRepository());
