class InterviewQuestion {
  final String question;
  final String topic;
  final String difficulty;
  final String? expectedAnswer;
  final String? audioUrl;

  const InterviewQuestion({
    required this.question,
    required this.topic,
    required this.difficulty,
    this.expectedAnswer,
    this.audioUrl,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      question: (json['question'] ?? '') as String,
      topic: (json['topic'] ?? '') as String,
      difficulty: (json['difficulty'] ?? '') as String,
      expectedAnswer: json['expectedAnswer'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }
}

class InterviewTranscript {
  final String speaker;
  final String text;
  final DateTime timestamp;

  const InterviewTranscript({
    required this.speaker,
    required this.text,
    required this.timestamp,
  });

  factory InterviewTranscript.fromJson(Map<String, dynamic> json) {
    return InterviewTranscript(
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'speaker': speaker,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };
}

class InterviewConfig {
  final List<String>? techStack;
  final int? experience;
  final String? experienceLevel;
  final int? duration;
  final String? voicePreference;
  final String? resumeUrl;

  const InterviewConfig({
    this.techStack,
    this.experience,
    this.experienceLevel,
    this.duration,
    this.voicePreference,
    this.resumeUrl,
  });

  factory InterviewConfig.fromJson(Map<String, dynamic> json) {
    return InterviewConfig(
      techStack: (json['techStack'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      experience: (json['experience'] as num?)?.toInt(),
      experienceLevel:
          (json['experienceLevel'] ?? json['experience']?.toString())
              as String?,
      duration: (json['duration'] as num?)?.toInt(),
      voicePreference: (json['voicePreference'] ?? json['voice']) as String?,
      resumeUrl: json['resumeUrl'] as String?,
    );
  }
}

class InterviewSession {
  final String id;
  final String type;
  final String status;
  final InterviewConfig? config;
  final List<InterviewQuestion> questions;
  final List<InterviewTranscript> transcript;
  final int currentQuestionIndex;
  final String? feedbackId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;

  const InterviewSession({
    required this.id,
    required this.type,
    required this.status,
    this.config,
    required this.questions,
    required this.transcript,
    required this.currentQuestionIndex,
    this.feedbackId,
    this.startedAt,
    this.completedAt,
    this.createdAt,
  });

  factory InterviewSession.fromJson(Map<String, dynamic> json) {
    return InterviewSession(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      config: json['config'] != null
          ? InterviewConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => InterviewQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      transcript: (json['transcript'] as List<dynamic>? ?? [])
          .map((t) => InterviewTranscript.fromJson(t as Map<String, dynamic>))
          .toList(),
      currentQuestionIndex:
          (json['currentQuestionIndex'] as num?)?.toInt() ?? 0,
      feedbackId: json['feedbackId'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String? ?? '')
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String? ?? '')
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String? ?? '')
          : null,
    );
  }

  /// Duration in minutes based on config, fallback 30min
  int get durationMinutes => config?.duration ?? 30;

  /// Display-friendly type label
  String get typeLabel => switch (type) {
    'resume' => 'RESUME BASED',
    'normal' => 'TECHNICAL',
    _ => type.toUpperCase(),
  };

  /// Rough duration string from session start/end
  String get durationDisplay {
    if (startedAt != null && completedAt != null) {
      final diff = completedAt!.difference(startedAt!).inMinutes;
      return '${diff}m';
    }
    return '${durationMinutes}m';
  }
}
