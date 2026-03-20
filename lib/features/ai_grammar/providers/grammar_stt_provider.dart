import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/core/services/deepgram_stt_service.dart';

class GrammarSttState {
  final String transcript;
  final bool isListening;
  final String? error;

  GrammarSttState({
    this.transcript = '',
    this.isListening = false,
    this.error,
  });

  GrammarSttState copyWith({
    String? transcript,
    bool? isListening,
    String? error,
  }) {
    return GrammarSttState(
      transcript: transcript ?? this.transcript,
      isListening: isListening ?? this.isListening,
      error: error ?? this.error,
    );
  }
}

class GrammarSttNotifier extends Notifier<GrammarSttState> {
  final _sttService = DeepgramSttService();

  @override
  GrammarSttState build() {
    return GrammarSttState();
  }

  Future<void> startListening() async {
    state = state.copyWith(isListening: true, transcript: '', error: null);
    await _sttService.start(
      onTranscript: (t) {
        state = state.copyWith(transcript: t);
      },
      onError: (e) {
        state = state.copyWith(error: e, isListening: false);
      },
      onDone: () {
        state = state.copyWith(isListening: false);
      },
    );
  }

  Future<void> stopListening() async {
    await _sttService.stop();
    state = state.copyWith(isListening: false);
  }

  Future<void> toggleListening() async {
    if (state.isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }
}

final grammarSttProvider = NotifierProvider<GrammarSttNotifier, GrammarSttState>(
  GrammarSttNotifier.new,
);
