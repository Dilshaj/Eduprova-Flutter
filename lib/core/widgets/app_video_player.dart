import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart' as vp;

enum AppVideoEngine { mediaKit, videoPlayer }

class AppVideoPlayer extends StatefulWidget {
  final String? url;
  final String? muxPlaybackId;
  final bool autoPlay;
  final AppVideoEngine engine;

  const AppVideoPlayer({
    super.key,
    this.url,
    this.muxPlaybackId,
    this.autoPlay = true,
    this.engine = AppVideoEngine.mediaKit,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  late final Player _mediaPlayer = Player();
  late final VideoController _mediaController = VideoController(_mediaPlayer);
  vp.VideoPlayerController? _videoController;
  String? _mediaUrl;
  bool _isFullscreen = false;
  bool _isPresentingFullscreen = false;

  Duration _mediaPosition = Duration.zero;
  Duration _mediaDuration = Duration.zero;
  bool _mediaPlaying = false;

  double _volume = 1.0;
  double _brightness = 1.0;
  final List<StreamSubscription<dynamic>> _mediaSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _listenToMediaKit();
    _initVideo();
  }

  void _listenToMediaKit() {
    _mediaSubscriptions.add(_mediaPlayer.stream.position.listen((value) {
      _mediaPosition = value;
      if (mounted) setState(() {});
    }));
    _mediaSubscriptions.add(_mediaPlayer.stream.duration.listen((value) {
      _mediaDuration = value;
      if (mounted) setState(() {});
    }));
    _mediaSubscriptions.add(_mediaPlayer.stream.playing.listen((value) {
      _mediaPlaying = value;
      if (mounted) setState(() {});
    }));
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
      await _mediaPlayer.open(Media(_mediaUrl!), play: widget.autoPlay);
      await _mediaPlayer.setVolume(_volume * 100);
      return;
    }

    _videoController?.removeListener(_onVideoControllerChanged);
    await _videoController?.dispose();
    final controller = vp.VideoPlayerController.networkUrl(
      Uri.parse(_mediaUrl!),
    );
    _videoController = controller;
    await controller.initialize();
    controller.addListener(_onVideoControllerChanged);
    await controller.setVolume(_volume);
    if (widget.autoPlay) {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.muxPlaybackId != widget.muxPlaybackId ||
        oldWidget.engine != widget.engine) {
      _initVideo();
    }
  }

  @override
  void dispose() {
    for (final subscription in _mediaSubscriptions) {
      subscription.cancel();
    }
    _videoController?.removeListener(_onVideoControllerChanged);
    _videoController?.dispose();
    _mediaPlayer.dispose();
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
    final duration = _duration();
    if (duration <= Duration.zero) return;

    final current = _currentPosition();
    final target = Duration(
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
    if (duration <= Duration.zero) return;
    final normalized = Duration(
      milliseconds: target.inMilliseconds.clamp(0, duration.inMilliseconds),
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
        transitionsBuilder: (
          routeContext,
          animation,
          secondaryAnimation,
          child,
        ) {
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
      child: _buildEngineVideo(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return Container(color: Colors.black);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black,
        child: _buildInteractiveLayer(fullscreen: false),
      ),
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
  bool _isScrubbing = false;
  double _scrubMs = 0;
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
    final isLeft = details.localPosition.dx < constraints.maxWidth / 2;
    final by = isLeft ? -_skipSeconds : _skipSeconds;
    await widget.onSeekBySeconds(by);
    _showOverlay(
      type: OverlayType.seek,
      text: isLeft ? '-${_skipSeconds}s' : '+${_skipSeconds}s',
      icon: isLeft ? Icons.replay_10 : Icons.forward_10,
    );
    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }
    _scheduleControlsHide();
  }

  void _handlePanStart(DragStartDetails details, BoxConstraints constraints) {
    final x = details.localPosition.dx;
    _dragDistance = constraints.maxHeight * 0.45;
    _panDx = 0;
    _panDy = 0;
    _dragDy = 0;
    _gestureMode = _GestureMode.none;
    if (!widget.fullscreen) {
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
      final next = (widget.brightness + (-details.delta.dy / 260)).clamp(
        0.2,
        1.0,
      );
      widget.onBrightnessChanged(next);
      _showOverlay(
        type: OverlayType.brightness,
        text: 'Brightness ${(next * 100).round()}%',
        icon: Icons.brightness_6_rounded,
      );
      return;
    }
    if (_gestureMode == _GestureMode.volume) {
      final next = (widget.volume + (-details.delta.dy / 260)).clamp(0.0, 1.0);
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
        if (!widget.fullscreen && _dragDy > 0) _dragDy = 0;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final progress = (_dragDy.abs() / _dragDistance).clamp(0.0, 1.0);
    if (_gestureMode == _GestureMode.fullscreenDrag) {
      if (!widget.fullscreen && (velocity < -500 || progress > 0.28)) {
        widget.onFullscreenRequested();
      } else if (widget.fullscreen && (velocity > 500 || progress > 0.22)) {
        widget.onExitFullscreenRequested();
      } else {
        setState(() {
          _dragDy = 0;
        });
      }
    }
    _gestureMode = _GestureMode.none;
    _panDx = 0;
    _panDy = 0;
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
        final translateY = widget.fullscreen
            ? _dragDy.clamp(0.0, constraints.maxHeight.toDouble())
            : _dragDy.clamp(-constraints.maxHeight.toDouble(), 0.0);
        final scale = widget.fullscreen
            ? (1 - (dragProgress * 0.18))
            : (1 + (dragProgress * 0.08));
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTapDown: (details) => _onDoubleTap(details, constraints),
          onTap: _toggleControls,
          onVerticalDragStart: (details) => _handlePanStart(details, constraints),
          onVerticalDragUpdate: _handlePanUpdate,
          onVerticalDragEnd: _handlePanEnd,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            offset: Offset(
              0,
              translateY / constraints.maxHeight,
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              scale: scale,
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
                                    overlayShape: SliderComponentShape.noOverlay,
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
                                      onPressed: widget.fullscreen
                                          ? widget.onExitFullscreenRequested
                                          : widget.onFullscreenRequested,
                                      icon: Icon(
                                        widget.fullscreen
                                            ? Icons.fullscreen_exit_rounded
                                            : Icons.fullscreen_rounded,
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

enum OverlayType { seek, volume, brightness }
