import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'video_controls.dart';
import 'settings_sheet.dart';

class CourseVideoPlayer extends StatefulWidget {
  final VoidCallback onBackPress;
  final ValueChanged<bool>? onMiniPlayerChange;
  final ValueChanged<bool>? onFullscreenChange;
  final String videoUrl;

  const CourseVideoPlayer({
    super.key,
    required this.onBackPress,
    this.onMiniPlayerChange,
    this.onFullscreenChange,
    required this.videoUrl, // passing string URL for the video
  });

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _isMuted = false;
  bool _controlsVisible = false;
  bool _showSettings = false;

  // Playback settings
  String _quality = '1080p';
  double _speed = 1.0;
  int _seekPosition = 0;
  bool _isSeeking = false;

  // Layout states
  bool _isLandscape = false;

  // Double tap state
  bool _doubleTapVisible = false;
  int _doubleTapSeconds = 0;
  String? _doubleTapSide;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  void _initVideoPlayer() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
        _controller.addListener(() {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _restoreSystemUI();
    super.dispose();
  }

  void _restoreSystemUI() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _handleBackPress() {
    if (_isLandscape) {
      _toggleFullscreen();
    } else {
      widget.onBackPress();
    }
  }

  void _handleSeek(int millis) {
    if (_isInitialized) {
      _seekPosition = millis;
      _controller.seekTo(Duration(milliseconds: millis));
    }
  }

  void _handlePlayPause() {
    if (!_isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _startEnterFullscreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLandscape = true;
        });
        widget.onFullscreenChange?.call(true);
      }
    });
  }

  void _startExitFullscreen() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLandscape = false;
        });
        widget.onFullscreenChange?.call(false);
      }
    });
  }

  void _toggleFullscreen() {
    if (_isLandscape) {
      _startExitFullscreen();
    } else {
      _startEnterFullscreen();
    }
  }

  void _performSeek(int seconds, String side) {
    if (!_isInitialized) return;

    final currentPosition = _controller.value.position.inMilliseconds;
    final maxPosition = _controller.value.duration.inMilliseconds;

    int newPosition =
        currentPosition + (side == 'left' ? -seconds * 1000 : seconds * 1000);
    if (newPosition < 0) newPosition = 0;
    if (newPosition > maxPosition) newPosition = maxPosition;

    _controller.seekTo(Duration(milliseconds: newPosition));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _doubleTapVisible = false;
          _doubleTapSeconds = 0;
          _doubleTapSide = null;
        });
      }
    });
  }

  void _handleDoubleTap(TapDownDetails details, double width) {
    final side = details.localPosition.dx < width / 2 ? 'left' : 'right';

    setState(() {
      final isSameSide = _doubleTapSide == side;
      final newSeconds = (_doubleTapVisible && isSameSide)
          ? _doubleTapSeconds + 5
          : 5;

      _doubleTapVisible = true;
      _doubleTapSeconds = newSeconds;
      _doubleTapSide = side;

      // cancel previous Future and start new one? In Flutter standard way is a fresh timer, but we do simplified run logic
      _performSeek(newSeconds, side);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLandscape,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isLandscape) _toggleFullscreen();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: Colors.black,
            child: Stack(
              children: [
                // Video Player
                if (_isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _isLandscape
                          ? constraints.maxWidth / constraints.maxHeight
                          : _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0066FF)),
                  ),

                // Double Tap Areas overlay
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onDoubleTapDown: (d) =>
                              _handleDoubleTap(d, constraints.maxWidth),
                          onTap: () {
                            setState(() {
                              _controlsVisible = !_controlsVisible;
                            });
                          },
                          child: Container(
                            color: _doubleTapVisible && _doubleTapSide == 'left'
                                ? Colors.black.withValues(alpha: 0.4)
                                : Colors.transparent,
                            child: _doubleTapVisible && _doubleTapSide == 'left'
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.fast_rewind,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        Text(
                                          '$_doubleTapSeconds s',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onDoubleTapDown: (d) =>
                              _handleDoubleTap(d, constraints.maxWidth),
                          onTap: () {
                            setState(() {
                              _controlsVisible = !_controlsVisible;
                            });
                          },
                          child: Container(
                            color:
                                _doubleTapVisible && _doubleTapSide == 'right'
                                ? Colors.black.withValues(alpha: 0.4)
                                : Colors.transparent,
                            child:
                                _doubleTapVisible && _doubleTapSide == 'right'
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.fast_forward,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        Text(
                                          '$_doubleTapSeconds s',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ControlsOverlay
                if (_controlsVisible)
                  Positioned.fill(
                    child: VideoControls(
                      isPlaying: _controller.value.isPlaying,
                      duration: _controller.value.duration.inMilliseconds,
                      currentTime: _isSeeking
                          ? _seekPosition
                          : _controller.value.position.inMilliseconds,
                      isMuted: _isMuted,
                      isLoading: _isLoading || !_isInitialized,
                      onPlayPause: _handlePlayPause,
                      onSeek: _handleSeek,
                      onSeekStart: () {
                        setState(() {
                          _isSeeking = true;
                        });
                      },
                      onSeekComplete: (millis) {
                        setState(() {
                          _isSeeking = false;
                        });
                        _controller.seekTo(Duration(milliseconds: millis));
                      },
                      onToggleMute: () {
                        setState(() {
                          _isMuted = !_isMuted;
                          _controller.setVolume(_isMuted ? 0.0 : 1.0);
                        });
                      },
                      onToggleFullscreen: _toggleFullscreen,
                      onSettingsPress: () {
                        setState(() {
                          _showSettings = true;
                        });
                      },
                      onBackPress: _handleBackPress,
                      onHideControls: () {
                        setState(() {
                          _controlsVisible = false;
                        });
                      },
                    ),
                  ),

                // Settings Sheet
                if (_showSettings)
                  SettingsSheet(
                    visible: _showSettings,
                    onClose: () {
                      setState(() {
                        _showSettings = false;
                      });
                    },
                    currentQuality: _quality,
                    onQualityChange: (q) {
                      setState(() {
                        _quality = q;
                      });
                    },
                    currentSpeed: _speed,
                    onSpeedChange: (s) {
                      setState(() {
                        _speed = s;
                        _controller.setPlaybackSpeed(s);
                        _showSettings = false;
                      });
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
