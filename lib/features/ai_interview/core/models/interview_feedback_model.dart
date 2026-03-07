class DetailedAnalysisItem {
  final String question;
  final String userAnswer;
  final double score;
  final String feedback;
  final String detailedAnswer;

  const DetailedAnalysisItem({
    required this.question,
    required this.userAnswer,
    required this.score,
    required this.feedback,
    required this.detailedAnswer,
  });

  factory DetailedAnalysisItem.fromJson(Map<String, dynamic> json) {
    return DetailedAnalysisItem(
      question: json['question'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      feedback: json['feedback'] as String? ?? '',
      detailedAnswer: json['detailedAnswer'] as String? ?? '',
    );
  }
}

class InterviewFeedback {
  final String id;
  final String sessionId;
  final double overallScore;
  final double technicalScore;
  final double communicationScore;
  final List<String> strengths;
  final List<String> improvements;
  final List<DetailedAnalysisItem> detailedAnalysis;
  final List<String> recommendations;

  const InterviewFeedback({
    required this.id,
    required this.sessionId,
    required this.overallScore,
    required this.technicalScore,
    required this.communicationScore,
    required this.strengths,
    required this.improvements,
    required this.detailedAnalysis,
    required this.recommendations,
  });

  factory InterviewFeedback.fromJson(Map<String, dynamic> json) {
    return InterviewFeedback(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      sessionId: (json['sessionId'] ?? '') as String,
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
      technicalScore: (json['technicalScore'] as num?)?.toDouble() ?? 0.0,
      communicationScore:
          (json['communicationScore'] as num?)?.toDouble() ?? 0.0,
      strengths:
          (json['strengths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      improvements:
          (json['improvements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      detailedAnalysis: (json['detailedAnalysis'] as List<dynamic>? ?? [])
          .map((e) => DetailedAnalysisItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
