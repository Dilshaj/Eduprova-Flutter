import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart' as vp;

enum AppVideoEngine { mediaKit, videoPlayer }

class AppVideoMiniSnapshot {
  final String mediaUrl;
  final AppVideoEngine engine;
  final Duration position;
  final bool isPlaying;
  final double volume;
  final Player? mediaPlayer;
  final vp.VideoPlayerController? videoPlayerController;
  final String? restoreRoute;

  const AppVideoMiniSnapshot({
    required this.mediaUrl,
    required this.engine,
    required this.position,
    required this.isPlaying,
    required this.volume,
    this.mediaPlayer,
    this.videoPlayerController,
    this.restoreRoute,
  });
}

class AppVideoPlayerController {
  VoidCallback? _exitMiniPlayer;
  bool _isMiniPlayer = false;

  bool get isMiniPlayer => _isMiniPlayer;

  void exitMiniPlayer() => _exitMiniPlayer?.call();
}

class AppVideoPlayer extends StatefulWidget {
  final String? url;
  final String? muxPlaybackId;
  final bool autoPlay;
  final Duration? initialPosition;
  final AppVideoEngine engine;
  final Player? adoptedMediaPlayer;
  final vp.VideoPlayerController? adoptedVideoPlayerController;
  final AppVideoPlayerController? controller;
  final ValueChanged<bool>? onMiniPlayerChanged;
  final ValueChanged<double>? onInlineCollapseProgress;
  final bool Function(AppVideoMiniSnapshot snapshot)? onInlineMiniPlayerRequest;
  final double inlineMiniBottomInset;
  final String? restoreRouteOnExpand;

  const AppVideoPlayer({
    super.key,
    this.url,
    this.muxPlaybackId,
    this.autoPlay = true,
    this.initialPosition,
    this.engine = AppVideoEngine.mediaKit,
    this.adoptedMediaPlayer,
    this.adoptedVideoPlayerController,
    this.controller,
    this.onMiniPlayerChanged,
    this.onInlineCollapseProgress,
    this.onInlineMiniPlayerRequest,
    this.inlineMiniBottomInset = 0,
    this.restoreRouteOnExpand,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  late Player _mediaPlayer;
  late VideoController _mediaController;
  bool _ownsMediaPlayer = true;
  vp.VideoPlayerController? _videoController;
  bool _ownsVideoController = true;
  String? _mediaUrl;
  bool _isFullscreen = false;
  bool _isPresentingFullscreen = false;
  bool _isMiniPip = false;
  OverlayEntry? _pipOverlayEntry;
  bool _transferredToGlobalMini = false;

  Duration _mediaPosition = Duration.zero;
  Duration _mediaDuration = Duration.zero;
  bool _mediaPlaying = false;

  double _volume = 1.0;
  double _brightness = 1.0;
  final List<StreamSubscription<dynamic>> _mediaSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _mediaPlayer = widget.adoptedMediaPlayer ?? Player();
    _mediaController = VideoController(_mediaPlayer);
    _ownsMediaPlayer = widget.adoptedMediaPlayer == null;
    _videoController = widget.adoptedVideoPlayerController;
    _ownsVideoController = widget.adoptedVideoPlayerController == null;
    _videoController?.addListener(_onVideoControllerChanged);
    _bindExternalController();
    _listenToMediaKit();
    _initVideo();
  }

  void _bindExternalController() {
    widget.controller?._exitMiniPlayer = _exitMiniPip;
    widget.controller?._isMiniPlayer = _isMiniPip;
  }

  void _listenToMediaKit() {
    _mediaSubscriptions.add(
      _mediaPlayer.stream.position.listen((value) {
        _mediaPosition = value;
        if (mounted) setState(() {});
      }),
    );
    _mediaSubscriptions.add(
      _mediaPlayer.stream.duration.listen((value) {
        _mediaDuration = value;
        if (mounted) setState(() {});
      }),
    );
    _mediaSubscriptions.add(
      _mediaPlayer.stream.playing.listen((value) {
        _mediaPlaying = value;
        if (mounted) setState(() {});
      }),
    );
  }

  void _initVideo() {
    String? mediaUrl = widget.url;

    if (widget.muxPlaybackId != null && widget.muxPlaybackId!.isNotEmpty) {
      mediaUrl = 'https://stream.mux.com/${widget.muxPlaybackId}.m3u8';
    }

    _mediaUrl = mediaUrl;
    if (_mediaUrl == null || _mediaUrl!.isEmpty) return;
    _openWithActiveEngine();
  }

  Future<void> _openWithActiveEngine() async {
    if (_mediaUrl == null || _mediaUrl!.isEmpty) return;

    if (widget.engine == AppVideoEngine.mediaKit) {
      if (!_ownsMediaPlayer) {
        final initial = widget.initialPosition;
        if (initial != null && initial > Duration.zero) {
          await _mediaPlayer.seek(initial);
        }
        await _mediaPlayer.setVolume(_volume * 100);
        if (widget.autoPlay) {
          await _mediaPlayer.play();
        }
        return;
      }
      await _mediaPlayer.open(Media(_mediaUrl!), play: false);
      final initial = widget.initialPosition;
      if (initial != null && initial > Duration.zero) {
        await _mediaPlayer.seek(initial);
        await Future.delayed(const Duration(milliseconds: 120));
        await _mediaPlayer.seek(initial);
      }
      await _mediaPlayer.setVolume(_volume * 100);
      if (widget.autoPlay) {
        await _mediaPlayer.play();
        if (initial != null && initial > Duration.zero) {
          await Future.delayed(const Duration(milliseconds: 80));
          await _mediaPlayer.seek(initial);
        }
      }
      return;
    }

    if (!_ownsVideoController && _videoController != null) {
      final initial = widget.initialPosition;
      if (initial != null && initial > Duration.zero) {
        await _videoController!.seekTo(initial);
      }
      await _videoController!.setVolume(_volume);
      if (widget.autoPlay) {
        await _videoController!.play();
      }
      if (mounted) setState(() {});
      return;
    }

    _videoController?.removeListener(_onVideoControllerChanged);
    if (_ownsVideoController) {
      await _videoController?.dispose();
    }
    final controller = vp.VideoPlayerController.networkUrl(
      Uri.parse(_mediaUrl!),
    );
    _videoController = controller;
    await controller.initialize();
    controller.addListener(_onVideoControllerChanged);
    final initial = widget.initialPosition;
    if (initial != null && initial > Duration.zero) {
      await controller.seekTo(initial);
    }
    await controller.setVolume(_volume);
    if (widget.autoPlay) {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._exitMiniPlayer = null;
      _bindExternalController();
    }
    if (oldWidget.url != widget.url ||
        oldWidget.muxPlaybackId != widget.muxPlaybackId ||
        oldWidget.engine != widget.engine) {
      _initVideo();
    }
  }

  @override
  void dispose() {
    widget.controller?._exitMiniPlayer = null;
    _removePipOverlay();
    for (final subscription in _mediaSubscriptions) {
      subscription.cancel();
    }
    _videoController?.removeListener(_onVideoControllerChanged);
    if (!_transferredToGlobalMini) {
      if (_ownsVideoController) {
        _videoController?.dispose();
      }
      if (_ownsMediaPlayer) {
        _mediaPlayer.dispose();
      }
    } else {
      // Ownership moved to global mini overlay/session.
      _ownsVideoController = false;
      _ownsMediaPlayer = false;
    }
    super.dispose();
  }

  void _onVideoControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayPause() async {
    if (widget.engine == AppVideoEngine.mediaKit) {
      if (_mediaPlaying) {
        await _mediaPlayer.pause();
      } else {
        await _mediaPlayer.play();
      }
      return;
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  Duration _currentPosition() {
    if (widget.engine == AppVideoEngine.mediaKit) return _mediaPosition;
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return Duration.zero;
    }
    return controller.value.position;
  }

  Duration _duration() {
    if (widget.engine == AppVideoEngine.mediaKit) return _mediaDuration;
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return Duration.zero;
    }
    return controller.value.duration;
  }

  bool _isPlaying() {
    if (widget.engine == AppVideoEngine.mediaKit) return _mediaPlaying;
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return false;
    return controller.value.isPlaying;
  }

  Future<void> _seekBySeconds(int seconds) async {
    final current = _currentPosition();
    final duration = _duration();
    final target = duration <= Duration.zero
        ? Duration(
            milliseconds: (current.inMilliseconds + (seconds * 1000)).clamp(
              0,
              1 << 31,
            ),
          )
        : Duration(
            milliseconds: (current.inMilliseconds + (seconds * 1000)).clamp(
              0,
              duration.inMilliseconds,
            ),
          );

    if (widget.engine == AppVideoEngine.mediaKit) {
      await _mediaPlayer.seek(target);
      return;
    }
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.seekTo(target);
    }
  }

  Future<void> _seekTo(Duration target) async {
    final duration = _duration();
    final normalized = duration <= Duration.zero
        ? Duration(milliseconds: target.inMilliseconds.clamp(0, 1 << 31))
        : Duration(
            milliseconds: target.inMilliseconds.clamp(
              0,
              duration.inMilliseconds,
            ),
          );

    if (widget.engine == AppVideoEngine.mediaKit) {
      await _mediaPlayer.seek(normalized);
      return;
    }
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.seekTo(normalized);
    }
  }

  Future<void> _setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    if (widget.engine == AppVideoEngine.mediaKit) {
      await _mediaPlayer.setVolume(_volume * 100);
      return;
    }
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.setVolume(_volume);
    }
  }

  void _setBrightness(double value) {
    setState(() {
      _brightness = value.clamp(0.2, 1.0);
    });
  }

  Future<void> _enterFullscreen() async {
    if (_isPresentingFullscreen) return;
    if (_isMiniPip) {
      _isMiniPip = false;
      _removePipOverlay();
    }
    final navigator = Navigator.of(context);
    _isPresentingFullscreen = true;
    setState(() {
      _isFullscreen = true;
    });

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await navigator.push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (routeContext, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              top: false,
              bottom: false,
              child: _buildInteractiveLayer(fullscreen: true),
            ),
          );
        },
        transitionsBuilder:
            (routeContext, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
      ),
    );

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!mounted) return;
    setState(() {
      _isFullscreen = false;
      _isPresentingFullscreen = false;
    });
  }

  void _exitFullscreen() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _enterMiniPip() {
    if (_isMiniPip || _isFullscreen || !mounted) return;
    setState(() {
      _isMiniPip = true;
    });
    widget.onInlineCollapseProgress?.call(1);
    widget.controller?._isMiniPlayer = true;
    widget.onMiniPlayerChanged?.call(true);
    _showPipOverlay();
  }

  void _handleMiniPlayerRequested() {
    final mediaUrl = _mediaUrl;
    if (mediaUrl == null || mediaUrl.isEmpty) {
      _enterMiniPip();
      return;
    }
    final snapshot = AppVideoMiniSnapshot(
      mediaUrl: mediaUrl,
      engine: widget.engine,
      position: _currentPosition(),
      isPlaying: _isPlaying(),
      volume: _volume,
      mediaPlayer: widget.engine == AppVideoEngine.mediaKit
          ? _mediaPlayer
          : null,
      videoPlayerController: widget.engine == AppVideoEngine.videoPlayer
          ? _videoController
          : null,
      restoreRoute: widget.restoreRouteOnExpand,
    );
    final handled = widget.onInlineMiniPlayerRequest?.call(snapshot) ?? false;
    if (!handled) {
      _enterMiniPip();
    } else {
      _transferredToGlobalMini = true;
    }
  }

  void _exitMiniPip() {
    if (!_isMiniPip) return;
    setState(() {
      _isMiniPip = false;
    });
    widget.controller?._isMiniPlayer = false;
    widget.onInlineCollapseProgress?.call(0);
    widget.onMiniPlayerChanged?.call(false);
    _removePipOverlay();
  }

  void _showPipOverlay() {
    _removePipOverlay();
    final overlay = Overlay.of(context, rootOverlay: true);
    _pipOverlayEntry = OverlayEntry(
      builder: (context) {
        final padding = MediaQuery.of(context).padding;
        final miniWidth = _miniWidth(MediaQuery.sizeOf(context).width);
        return Positioned(
          right: 12,
          bottom: padding.bottom + 12 + widget.inlineMiniBottomInset,
          width: miniWidth,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _exitMiniPip,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.black,
                        child: _buildEngineVideo(),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: _exitMiniPip,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_pipOverlayEntry!);
  }

  double _miniWidth(double screenWidth) {
    return (screenWidth * 0.42).clamp(168.0, 220.0);
  }

  void _removePipOverlay() {
    _pipOverlayEntry?.remove();
    _pipOverlayEntry = null;
  }

  Widget _buildEngineVideo() {
    if (_mediaUrl == null || _mediaUrl!.isEmpty) {
      return const Center(
        child: Icon(Icons.play_disabled_outlined, color: Colors.white54),
      );
    }

    if (widget.engine == AppVideoEngine.mediaKit) {
      return Video(
        controller: _mediaController,
        fit: BoxFit.contain,
        controls: NoVideoControls,
      );
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: Colors.white70,
        ),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: vp.VideoPlayer(controller),
      ),
    );
  }

  Widget _buildInteractiveLayer({required bool fullscreen}) {
    return _GestureVideoLayer(
      fullscreen: fullscreen,
      isPlaying: _isPlaying(),
      position: _currentPosition(),
      duration: _duration(),
      brightness: _brightness,
      volume: _volume,
      onTogglePlayPause: _togglePlayPause,
      onSeekTo: _seekTo,
      onSeekBySeconds: _seekBySeconds,
      onVolumeChanged: (value) async {
        setState(() {
          _volume = value.clamp(0.0, 1.0);
        });
        await _setVolume(_volume);
      },
      onBrightnessChanged: _setBrightness,
      onFullscreenRequested: _enterFullscreen,
      onExitFullscreenRequested: _exitFullscreen,
      onMiniPlayerRequested: _handleMiniPlayerRequested,
      onInlineCollapseProgressChanged: widget.onInlineCollapseProgress,
      inlineMiniWidth: _miniWidth(MediaQuery.sizeOf(context).width),
      inlineMiniBottomInset: widget.inlineMiniBottomInset,
      child: _buildEngineVideo(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return Container(color: Colors.black);
    }
    if (_isMiniPip) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          'Playing in mini player',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }
    return Container(
      color: Colors.transparent,
      child: _buildInteractiveLayer(fullscreen: false),
    );
  }
}

class _GestureVideoLayer extends StatefulWidget {
  final Widget child;
  final bool fullscreen;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double brightness;
  final double volume;
  final Future<void> Function() onTogglePlayPause;
  final Future<void> Function(Duration target) onSeekTo;
  final Future<void> Function(int seconds) onSeekBySeconds;
  final Future<void> Function(double value) onVolumeChanged;
  final ValueChanged<double> onBrightnessChanged;
  final VoidCallback onFullscreenRequested;
  final VoidCallback onExitFullscreenRequested;
  final VoidCallback onMiniPlayerRequested;
  final ValueChanged<double>? onInlineCollapseProgressChanged;
  final double inlineMiniWidth;
  final double inlineMiniBottomInset;

  const _GestureVideoLayer({
    required this.child,
    required this.fullscreen,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.brightness,
    required this.volume,
    required this.onTogglePlayPause,
    required this.onSeekTo,
    required this.onSeekBySeconds,
    required this.onVolumeChanged,
    required this.onBrightnessChanged,
    required this.onFullscreenRequested,
    required this.onExitFullscreenRequested,
    required this.onMiniPlayerRequested,
    this.onInlineCollapseProgressChanged,
    required this.inlineMiniWidth,
    required this.inlineMiniBottomInset,
  });

  @override
  State<_GestureVideoLayer> createState() => _GestureVideoLayerState();
}

class _GestureVideoLayerState extends State<_GestureVideoLayer> {
  static const int _skipSeconds = 15;
  OverlayType? _overlayType;
  String _overlayText = '';
  IconData _overlayIcon = Icons.volume_up;
  _GestureMode _gestureMode = _GestureMode.none;
  Timer? _controlsTimer;
  bool _controlsVisible = false;
  double _dragDy = 0;
  double _dragDistance = 1;
  double _panDx = 0;
  double _panDy = 0;
  double _gestureDeltaY = 0;
  double _startVolume = 1.0;
  double _startBrightness = 1.0;
  bool _isScrubbing = false;
  double _scrubMs = 0;
  double _inlineMiniTargetDy = 1;
  bool _isSettlingToMini = false;
  _GestureZone _zone = _GestureZone.center;

  @override
  void dispose() {
    _controlsTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _GestureVideoLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controlsVisible && oldWidget.isPlaying != widget.isPlaying) {
      _scheduleControlsHide();
    }
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    _scheduleControlsHide();
  }

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    if (!_controlsVisible) return;
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _controlsVisible = false;
      });
    });
  }

  void _showOverlay({
    required OverlayType type,
    required String text,
    required IconData icon,
  }) {
    if (!mounted) return;
    setState(() {
      _overlayType = type;
      _overlayText = text;
      _overlayIcon = icon;
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      if (_overlayType != type) return;
      setState(() {
        _overlayType = null;
      });
    });
  }

  void _onDoubleTap(TapDownDetails details, BoxConstraints constraints) async {
    final dx = details.localPosition.dx;
    final third = constraints.maxWidth / 3;
    if (dx < third) {
      await widget.onSeekBySeconds(-_skipSeconds);
      _showOverlay(
        type: OverlayType.seek,
        text: '-${_skipSeconds}s',
        icon: Icons.replay_10,
      );
    } else if (dx > third * 2) {
      await widget.onSeekBySeconds(_skipSeconds);
      _showOverlay(
        type: OverlayType.seek,
        text: '+${_skipSeconds}s',
        icon: Icons.forward_10,
      );
    } else {
      final willPlay = !widget.isPlaying;
      await widget.onTogglePlayPause();
      _showOverlay(
        type: OverlayType.playback,
        text: willPlay ? 'Play' : 'Pause',
        icon: willPlay ? Icons.play_arrow_rounded : Icons.pause,
      );
    }
    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }
    _scheduleControlsHide();
  }

  void _handlePanStart(DragStartDetails details, BoxConstraints constraints) {
    _isSettlingToMini = false;
    final x = details.localPosition.dx;
    _dragDistance = widget.fullscreen
        ? constraints.maxHeight * 0.45
        : constraints.maxHeight * 0.9;
    _panDx = 0;
    _panDy = 0;
    _gestureDeltaY = 0;
    _dragDy = 0;
    _gestureMode = _GestureMode.none;
    _startVolume = widget.volume;
    _startBrightness = widget.brightness;
    if (!widget.fullscreen) {
      final mediaQuery = MediaQuery.of(context);
      final miniHeight = widget.inlineMiniWidth * (9 / 16);
      _inlineMiniTargetDy =
          mediaQuery.size.height -
          mediaQuery.padding.bottom -
          widget.inlineMiniBottomInset -
          miniHeight -
          12;
      if (_inlineMiniTargetDy < 1) _inlineMiniTargetDy = 1;
      // In inline/small mode only allow center vertical swipe for fullscreen.
      _zone = _GestureZone.center;
      return;
    }
    if (x < 28 || x > constraints.maxWidth - 28) {
      _zone = _GestureZone.edge;
      return;
    }
    if (x < constraints.maxWidth * 0.35) {
      _zone = _GestureZone.left;
    } else if (x > constraints.maxWidth * 0.65) {
      _zone = _GestureZone.right;
    } else {
      _zone = _GestureZone.center;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isSettlingToMini) return;
    if (_zone == _GestureZone.edge) return;
    _panDx += details.delta.dx.abs();
    _panDy += details.delta.dy.abs();

    final isMostlyVertical = _panDy > (_panDx * 1.2);
    if (_gestureMode == _GestureMode.none && _panDy > 8 && isMostlyVertical) {
      if (_zone == _GestureZone.center) {
        _gestureMode = _GestureMode.fullscreenDrag;
      } else if (_zone == _GestureZone.left) {
        _gestureMode = _GestureMode.brightness;
      } else if (_zone == _GestureZone.right) {
        _gestureMode = _GestureMode.volume;
      }
    }

    if (_gestureMode == _GestureMode.brightness) {
      _gestureDeltaY += details.delta.dy;
      final next = (_startBrightness + (-_gestureDeltaY / 260)).clamp(0.2, 1.0);
      widget.onBrightnessChanged(next);
      _showOverlay(
        type: OverlayType.brightness,
        text: 'Brightness ${(next * 100).round()}%',
        icon: Icons.brightness_6_rounded,
      );
      return;
    }
    if (_gestureMode == _GestureMode.volume) {
      _gestureDeltaY += details.delta.dy;
      final next = (_startVolume + (-_gestureDeltaY / 260)).clamp(0.0, 1.0);
      widget.onVolumeChanged(next);
      _showOverlay(
        type: OverlayType.volume,
        text: 'Volume ${(next * 100).round()}%',
        icon: next < 0.05 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
      );
      return;
    }

    if (_gestureMode == _GestureMode.fullscreenDrag) {
      setState(() {
        _dragDy += details.delta.dy;
        if (widget.fullscreen && _dragDy < 0) _dragDy = 0;
      });
      if (!widget.fullscreen) {
        final progressDown =
            ((_dragDy).clamp(0.0, _dragDistance) / _dragDistance).clamp(
              0.0,
              1.0,
            );
        widget.onInlineCollapseProgressChanged?.call(progressDown);
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final progressUp = ((-_dragDy).clamp(0.0, _dragDistance) / _dragDistance)
        .clamp(0.0, 1.0);
    final progressDown =
        ((_dragDy).clamp(0.0, _inlineMiniTargetDy) / _inlineMiniTargetDy).clamp(
          0.0,
          1.0,
        );
    if (_gestureMode == _GestureMode.fullscreenDrag) {
      if (!widget.fullscreen && (velocity < -500 || progressUp > 0.28)) {
        widget.onFullscreenRequested();
      } else if (!widget.fullscreen &&
          (velocity > 1400 || progressDown > 0.92)) {
        _animateToMiniAndCommit(progressDown);
      } else if (widget.fullscreen && (velocity > 500 || progressDown > 0.22)) {
        widget.onExitFullscreenRequested();
      } else {
        setState(() {
          _dragDy = 0;
        });
      }
    }
    if (!widget.fullscreen) {
      widget.onInlineCollapseProgressChanged?.call(0);
    }
    _gestureMode = _GestureMode.none;
    _panDx = 0;
    _panDy = 0;
    _gestureDeltaY = 0;
  }

  void _animateToMiniAndCommit(double startProgress) {
    if (_isSettlingToMini) return;
    _isSettlingToMini = true;
    final startDy = _dragDy;
    final start = DateTime.now().millisecondsSinceEpoch;
    const totalMs = 140.0;

    void tick(Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final elapsed = DateTime.now().millisecondsSinceEpoch - start;
      final t = (elapsed / totalMs).clamp(0.0, 1.0);
      final eased = Curves.easeOutCubic.transform(t);
      final nextDy = lerpDouble(startDy, _inlineMiniTargetDy, eased)!;
      setState(() {
        _dragDy = nextDy;
      });
      final progressDown = (nextDy / _inlineMiniTargetDy).clamp(0.0, 1.0);
      widget.onInlineCollapseProgressChanged?.call(progressDown);
      if (t >= 1.0) {
        timer.cancel();
        _isSettlingToMini = false;
        widget.onInlineCollapseProgressChanged?.call(1);
        widget.onMiniPlayerRequested();
      }
    }

    widget.onInlineCollapseProgressChanged?.call(startProgress);
    Timer.periodic(const Duration(milliseconds: 16), tick);
  }

  String _format(Duration duration) {
    final total = duration.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '${h.toString()}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString()}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;
        final safePadding = mediaQuery.padding;
        final dragProgress = (_dragDy.abs() / _dragDistance).clamp(0.0, 1.0);
        final displayPosition = _isScrubbing
            ? Duration(milliseconds: _scrubMs.round())
            : widget.position;
        final totalMs = widget.duration.inMilliseconds <= 0
            ? 1.0
            : widget.duration.inMilliseconds.toDouble();
        final sliderValue = displayPosition.inMilliseconds
            .clamp(0, widget.duration.inMilliseconds)
            .toDouble();
        final miniHeight = widget.inlineMiniWidth * (9 / 16);
        final targetMiniTop =
            screenSize.height -
            safePadding.bottom -
            widget.inlineMiniBottomInset -
            miniHeight -
            12;
        final downProgress = widget.fullscreen
            ? 0.0
            : (_dragDy / targetMiniTop).clamp(0.0, 1.0);
        final scale = widget.fullscreen
            ? (1 - (dragProgress * 0.18))
            : (_dragDy >= 0
                  ? lerpDouble(
                      1.0,
                      widget.inlineMiniWidth / constraints.maxWidth,
                      downProgress,
                    )!
                  : (1 + (dragProgress * 0.08)));
        final targetTranslateX =
            constraints.maxWidth - (constraints.maxWidth * scale) - 12;
        final translateX = (!widget.fullscreen && _dragDy > 0)
            ? (targetTranslateX * downProgress)
            : 0.0;
        final translateY = widget.fullscreen
            ? _dragDy.clamp(0.0, constraints.maxHeight.toDouble())
            : (_dragDy > 0
                  ? (targetMiniTop * downProgress)
                  : _dragDy.clamp(-constraints.maxHeight.toDouble(), 0.0));
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTapDown: (details) => _onDoubleTap(details, constraints),
          onTap: _toggleControls,
          onVerticalDragStart: (details) =>
              _handlePanStart(details, constraints),
          onVerticalDragUpdate: _handlePanUpdate,
          onVerticalDragEnd: _handlePanEnd,
          child: Transform.translate(
            offset: Offset(translateX, translateY),
            child: Transform.scale(
              scale: scale,
              alignment: (!widget.fullscreen && _dragDy > 0)
                  ? Alignment.topLeft
                  : Alignment.center,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.child,
                  if (widget.brightness < 1)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: (1 - widget.brightness) * 0.45,
                        ),
                      ),
                    ),
                  AnimatedOpacity(
                    opacity: _overlayType == null ? 0 : 1,
                    duration: const Duration(milliseconds: 160),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_overlayIcon, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _overlayText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _controlsVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.36),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.52),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                onPressed: () async {
                                  await widget.onTogglePlayPause();
                                  _scheduleControlsHide();
                                },
                                iconSize: 30,
                                icon: Icon(
                                  widget.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (!widget.fullscreen) ...[
                              Positioned(
                                left: 8,
                                right: 8,
                                bottom: 14,
                                child: Row(
                                  children: [
                                    Text(
                                      '${_format(displayPosition)} / ${_format(widget.duration)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: widget.onFullscreenRequested,
                                      icon: const Icon(
                                        Icons.fullscreen_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2.8,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 5.5,
                                    ),
                                    overlayShape:
                                        SliderComponentShape.noOverlay,
                                    trackShape:
                                        const RoundedRectSliderTrackShape(),
                                  ),
                                  child: Slider(
                                    value: sliderValue,
                                    min: 0,
                                    max: totalMs,
                                    onChangeStart: (value) {
                                      setState(() {
                                        _isScrubbing = true;
                                        _scrubMs = value;
                                      });
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _scrubMs = value;
                                      });
                                    },
                                    onChangeEnd: (value) async {
                                      await widget.onSeekTo(
                                        Duration(milliseconds: value.round()),
                                      );
                                      setState(() {
                                        _isScrubbing = false;
                                      });
                                      _scheduleControlsHide();
                                    },
                                  ),
                                ),
                              ),
                            ] else
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 2.8,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 6,
                                        ),
                                        overlayShape:
                                            SliderComponentShape.noOverlay,
                                      ),
                                      child: Slider(
                                        value: sliderValue,
                                        min: 0,
                                        max: totalMs,
                                        onChangeStart: (value) {
                                          setState(() {
                                            _isScrubbing = true;
                                            _scrubMs = value;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            _scrubMs = value;
                                          });
                                        },
                                        onChangeEnd: (value) async {
                                          await widget.onSeekTo(
                                            Duration(
                                              milliseconds: value.round(),
                                            ),
                                          );
                                          setState(() {
                                            _isScrubbing = false;
                                          });
                                          _scheduleControlsHide();
                                        },
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${_format(displayPosition)} / ${_format(widget.duration)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed:
                                              widget.onExitFullscreenRequested,
                                          icon: const Icon(
                                            Icons.fullscreen_exit_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _GestureZone { left, center, right, edge }

enum _GestureMode { none, brightness, volume, fullscreenDrag }

enum OverlayType { seek, volume, brightness, playback }
