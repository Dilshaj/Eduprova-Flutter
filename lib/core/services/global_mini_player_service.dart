import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_player/video_player.dart' as vp;

import '../widgets/app_video_player.dart';

class GlobalMiniPlayerSession {
  final int id;
  final String mediaUrl;
  final AppVideoEngine engine;
  final Duration position;
  final bool shouldPlay;
  final double volume;
  final Player? mediaPlayer;
  final vp.VideoPlayerController? videoPlayerController;
  final String? restoreRoute;

  const GlobalMiniPlayerSession({
    required this.id,
    required this.mediaUrl,
    required this.engine,
    required this.position,
    required this.shouldPlay,
    required this.volume,
    this.mediaPlayer,
    this.videoPlayerController,
    this.restoreRoute,
  });
}

class GlobalMiniPlayerService {
  GlobalMiniPlayerService._();
  static final GlobalMiniPlayerService instance = GlobalMiniPlayerService._();

  final ValueNotifier<GlobalMiniPlayerSession?> session = ValueNotifier(null);
  int _counter = 0;
  GlobalMiniPlayerSession? _pendingHandoff;

  void start(AppVideoMiniSnapshot snapshot) {
    _counter += 1;
    session.value = GlobalMiniPlayerSession(
      id: _counter,
      mediaUrl: snapshot.mediaUrl,
      engine: snapshot.engine,
      position: snapshot.position,
      shouldPlay: snapshot.isPlaying,
      volume: snapshot.volume,
      mediaPlayer: snapshot.mediaPlayer,
      videoPlayerController: snapshot.videoPlayerController,
      restoreRoute: snapshot.restoreRoute,
    );
  }

  void close() {
    _pendingHandoff = null;
    session.value = null;
  }

  void hideForHandoff() {
    _pendingHandoff = session.value;
    session.value = null;
  }

  GlobalMiniPlayerSession? takePendingHandoff() {
    final value = _pendingHandoff;
    _pendingHandoff = null;
    return value;
  }

  void restorePendingIfAny() {
    if (_pendingHandoff != null) {
      session.value = _pendingHandoff;
      _pendingHandoff = null;
    }
  }
}
