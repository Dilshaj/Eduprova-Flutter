import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class GrammarAudioPlayerNotifier extends Notifier<bool> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    children: [],
  );
  bool _initialized = false;

  @override
  bool build() {
    ref.onDispose(() {
      _audioPlayer.dispose();
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      final isActuallyPlaying =
          playerState.playing &&
          playerState.processingState != ProcessingState.completed;
      if (state != isActuallyPlaying) {
        state = isActuallyPlaying;
      }
    });

    return false;
  }

  Future<void> addChunk(String base64String) async {
    if (base64String.isEmpty) return;
    try {
      final normalizedBase64 = base64String.trim().replaceAll(
        RegExp(r'\s+'),
        '',
      );
      final bytes = base64Decode(normalizedBase64);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/grammar_ai_${DateTime.now().microsecondsSinceEpoch}.mp3',
      );
      await tempFile.writeAsBytes(bytes);

      if (!_initialized) {
        await _audioPlayer.setAudioSource(_playlist, preload: true);
        _initialized = true;
      }

      await _playlist.add(AudioSource.file(tempFile.path));

      if (!_audioPlayer.playing) {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error adding grammar audio chunk: $e');
    }
  }

  Future<void> playBase64(String base64String) async {
    if (base64String.isEmpty) return;
    try {
      // Use Data URI for single chunk playback to avoid file I/O latency
      final normalizedBase64 = base64String.trim().replaceAll(
        RegExp(r'\s+'),
        '',
      );
      final dataUri = 'data:audio/mp3;base64,$normalizedBase64';

      await _audioPlayer.stop();
      await _playlist.clear();
      await _audioPlayer.seek(Duration.zero, index: 0);
      _initialized = false;

      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(dataUri)));
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing base64 audio: $e');
      // Fallback to chunk method if URI fails (though it shouldn't for base64)
      await addChunk(base64String);
    }
  }

  void stop() async {
    await _audioPlayer.stop();
    if (_initialized) {
      await _playlist.clear();
    }
    _initialized = false;
    state = false;
  }
}

final grammarAudioPlayerProvider =
    NotifierProvider<GrammarAudioPlayerNotifier, bool>(
      GrammarAudioPlayerNotifier.new,
    );
