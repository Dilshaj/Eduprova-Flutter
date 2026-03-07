import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eduprova/core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DeepgramSttService {
  static final DeepgramSttService _instance = DeepgramSttService._internal();
  factory DeepgramSttService() => _instance;
  DeepgramSttService._internal();

  final _record = AudioRecorder();
  WebSocketChannel? _channel;
  StreamSubscription? _audioSubscription;

  bool _isListening = false;
  bool get isListening => _isListening;

  String _currentBuffer = '';
  String _finalizedText = '';

  Function(String)? _onTranscript;
  Function(String)? _onError;
  Function()? _onDone;

  /// Starts streaming STT via Deepgram WebSocket
  /// [onTranscript] is called whenever new text (interim or final) is received.
  Future<void> start({
    required Function(String) onTranscript,
    Function(String)? onError,
    Function()? onDone,
  }) async {
    if (_isListening) return;

    _onTranscript = onTranscript;
    _onError = onError;
    _onDone = onDone;
    _currentBuffer = '';
    _finalizedText = '';

    try {
      // 1. Get temporary token from backend
      final response = await ApiClient.instance.get(
        '/interview/deepgram-token',
      );
      final token = response.data['token'];

      if (token == null || token.isEmpty) {
        throw Exception('Failed to get Deepgram token from backend');
      }

      // 2. Connect to Deepgram WebSocket
      // Explicitly specifying port 443 to avoid 'port 0' issues on some Android devices.
      // Using Authorization: Bearer header for JWT tokens as recommended by Deepgram.
      final wsUrl =
          'wss://api.deepgram.com:443/v1/listen?model=nova-2&language=en&interim_results=true&encoding=linear16&sample_rate=16000';

      debugPrint('Connecting to Deepgram: $wsUrl');

      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      _channel!.stream.listen(
        _onWsMessage,
        onError: (e) {
          debugPrint('Deepgram WS Error: $e');
          _onError?.call('Microphone connection error');
          stop();
        },
        onDone: () {
          debugPrint('Deepgram WS Closed');
          stop();
        },
      );

      // 3. Start Recording Stream
      if (await _record.hasPermission()) {
        final stream = await _record.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );

        _isListening = true;

        _audioSubscription = stream.listen((data) {
          if (_isListening && _channel != null) {
            _channel!.sink.add(data);
          }
        });
      } else {
        throw Exception('Microphone permission denied');
      }
    } catch (e) {
      debugPrint('Deepgram Start Error: $e');
      _onError?.call(e.toString());
      stop();
    }
  }

  void _onWsMessage(dynamic message) {
    try {
      final data = jsonDecode(message);

      if (data['type'] == 'Results') {
        final isFinal = data['is_final'] == true;
        final transcript =
            data['channel']['alternatives'][0]['transcript'] as String;

        if (transcript.isNotEmpty) {
          if (isFinal) {
            _finalizedText += ' $transcript';
            _currentBuffer = '';
          } else {
            _currentBuffer = transcript;
          }

          final fullText = '$_finalizedText $_currentBuffer'.trim();
          _onTranscript?.call(fullText);
        }
      }
    } catch (e) {
      debugPrint('Error parsing Deepgram message: $e');
    }
  }

  /// Stops listening, closes WS, and cleans up.
  Future<void> stop() async {
    if (!_isListening) return;
    _isListening = false;

    try {
      // Send close stream message to Deepgram securely (empty JSON)
      if (_channel != null) {
        _channel!.sink.add(jsonEncode({'type': 'CloseStream'}));
        await Future.delayed(const Duration(milliseconds: 200));
        _channel!.sink.close();
        _channel = null;
      }

      await _audioSubscription?.cancel();
      _audioSubscription = null;

      if (await _record.isRecording()) {
        await _record.stop();
      }

      _onDone?.call();
    } catch (e) {
      debugPrint('Deepgram Stop Error: $e');
    }
  }
}
