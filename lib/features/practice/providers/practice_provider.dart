import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/features/practice/repositories/practice_repository.dart';

final practiceRepositoryProvider = Provider((ref) => PracticeRepository());

class PracticeState {
  final Map<String, dynamic>? output;
  final bool isRunning;

  PracticeState({this.output, this.isRunning = false});

  PracticeState copyWith({
    Map<String, dynamic>? output,
    bool? isRunning,
    bool clearOutput = false,
  }) {
    return PracticeState(
      output: clearOutput ? null : (output ?? this.output),
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class PracticeNotifier extends Notifier<PracticeState> {
  @override
  PracticeState build() {
    return PracticeState();
  }

  void clearOutput() {
    state = state.copyWith(clearOutput: true);
  }

  void setOutput(Map<String, dynamic> output) {
    state = state.copyWith(output: output, isRunning: false);
  }

  Future<void> runCode({
    required String pistonName,
    required int judge0Id,
    required String filename,
    required String code,
    Map<String, dynamic>?
    mockResult, // Optional mock result if backend starts failing
  }) async {
    state = state.copyWith(isRunning: true, clearOutput: true);

    final repository = ref.read(practiceRepositoryProvider);
    final result = await repository.executeCode(
      pistonName: pistonName,
      judge0Id: judge0Id,
      filename: filename,
      code: code,
    );

    // If it failed to connect and mockResult is provided, use mock.
    if (result['message'] != null &&
        (result['message'] as String).contains('Failed to connect') &&
        mockResult != null) {
      state = state.copyWith(isRunning: false, output: mockResult);
      return;
    }

    state = state.copyWith(isRunning: false, output: result);
  }
}

final practiceProvider = NotifierProvider<PracticeNotifier, PracticeState>(
  PracticeNotifier.new,
);
