import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stories_provider.dart';
import 'status_progress_bar.dart';

class StatusViewScreen extends ConsumerStatefulWidget {
  final StatusProfile profile;
  final double pageOffset;
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final Function(double) onDrag;

  const StatusViewScreen({
    super.key,
    required this.profile,
    required this.pageOffset,
    required this.onComplete,
    required this.onPrevious,
    required this.onDrag,
  });

  @override
  ConsumerState<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends ConsumerState<StatusViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  bool _isPaused = false;
  bool _isMediaLoaded = false;
  double _dragY = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this);
    _animController.addListener(() {
      setState(() {});
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStatus();
      }
    });

    _loadStatus(_currentIndex);
  }

  @override
  void dispose() {
    _animController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  DateTime? _tapDownTime;

  @override
  void didUpdateWidget(StatusViewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageOffset != oldWidget.pageOffset) {
      if (widget.pageOffset.abs() > 0.01) {
        _animController.stop();
        _videoController?.pause();
      } else {
        if (!_isPaused) {
          _resumePlayback();
        }
      }
    }
  }

  void _resumePlayback() {
    if (!_isMediaLoaded) return; // Don't resume if media not loaded yet

    final item = widget.profile.statuses[_currentIndex];
    if (item.type == StatusType.video) {
      if (_videoController != null &&
          _videoController!.value.position < _videoController!.value.duration) {
        _videoController?.play();
      }
    } else {
      _animController.forward();
    }
  }

  void _onMediaLoaded() {
    if (mounted && !_isMediaLoaded) {
      setState(() {
        _isMediaLoaded = true;
      });
      if (widget.pageOffset.abs() <= 0.01 && !_isPaused) {
        _resumePlayback();
      }
    }
  }

  void _loadStatus(int index) {
    _animController.stop();
    _animController.reset();
    setState(() {
      _isMediaLoaded = false;
      _currentIndex = index;
    });

    final item = widget.profile.statuses[index];
    if (item.type == StatusType.video) {
      _loadVideo(item);
    } else {
      _loadImage(item);
    }

    _precacheNext();
    
    // Mark as seen as soon as we start viewing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(statusProfilesProvider.notifier).markAsSeen(widget.profile.id);
      }
    });
  }

  void _precacheNext() {
    if (_currentIndex < widget.profile.statuses.length - 1) {
      final nextItem = widget.profile.statuses[_currentIndex + 1];
      if (nextItem.type == StatusType.image) {
        // Delay to avoid MediaQuery exception in initState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            precacheImage(CachedNetworkImageProvider(nextItem.url), context);
          }
        });
      }
    }
  }

  Future<void> _loadVideo(StatusItem item) async {
    final oldController = _videoController;
    _videoController = VideoPlayerController.networkUrl(Uri.parse(item.url));
    await _videoController!.initialize();
    oldController?.dispose();

    _videoController!.addListener(() {
      if (_videoController!.value.isPlaying) {
        setState(() {}); // For progress
      }
      if (_videoController!.value.position >=
              _videoController!.value.duration &&
          _videoController!.value.duration.inMilliseconds > 0) {
        if (!_isPaused && mounted && widget.pageOffset.abs() <= 0.01) {
          _nextStatus();
        }
      }
    });

    if (mounted) {
      _onMediaLoaded();
    }
  }

  void _loadImage(StatusItem item) {
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }
    _animController.duration = item.duration;
    // We don't call forward() here anymore. 
    // It will be called in _onMediaLoaded via Image loading callbacks
  }

  void _nextStatus() {
    if (_currentIndex < widget.profile.statuses.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _loadStatus(_currentIndex);
    } else {
      widget.onComplete();
    }
  }

  void _prevStatus() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _loadStatus(_currentIndex);
    } else {
      widget.onPrevious();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _tapDownTime = DateTime.now();
    setState(() {
      _isPaused = true;
    });
    _animController.stop();
    _videoController?.pause();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isDragging) return;

    setState(() {
      _isPaused = false;
    });

    final int duration = _tapDownTime != null
        ? DateTime.now().difference(_tapDownTime!).inMilliseconds
        : 0;

    if (duration < 250) {
      final screenWidth = MediaQuery.sizeOf(context).width;

      // Top bar dead zone (prevents accidental skips when clicking UI items)
      if (details.globalPosition.dy < 100) return;

      // Define navigation zones
      if (details.globalPosition.dx < screenWidth * 0.25) {
        _prevStatus();
      } else {
        // Tapping anywhere else (except top bar) goes next
        _nextStatus();
      }
    } else {
      if (widget.pageOffset.abs() <= 0.01) {
        _resumePlayback();
      }
    }
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
    _animController.stop();
    _videoController?.pause();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy > 0 || _dragY > 0) {
      setState(() {
        _dragY += details.delta.dy;
        if (_dragY < 0) _dragY = 0;
      });

      // Notify parent to fade background only during drag
      final opacity = (1.0 - (_dragY / MediaQuery.sizeOf(context).height * 1.2)).clamp(0.0, 1.0);
      widget.onDrag(opacity);
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_dragY > 150) {
      _smoothClose();
    } else {
      setState(() {
        _isDragging = false;
        _dragY = 0;
      });
      widget.onDrag(1.0); // Restore solid background
      if (!_isPaused && widget.pageOffset.abs() <= 0.01) {
        _resumePlayback();
      }
    }
  }

  void _smoothClose() async {
    setState(() {
      _isDragging = false;
      _dragY = MediaQuery.sizeOf(context).height;
    });
    widget.onDrag(0.0); // Fully reveal background during exit
    // Wait for the slide down animation to complete before popping
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleTapCancel() {
    setState(() {
      _isPaused = false;
    });
    if (widget.pageOffset.abs() <= 0.01) {
      _resumePlayback();
    }
  }

  double get _currentProgress {
    if (!_isMediaLoaded) return 0.0;
    final item = widget.profile.statuses[_currentIndex];
    if (item.type == StatusType.video && _videoController != null) {
      if (!_videoController!.value.isInitialized) return 0.0;
      final dur = _videoController!.value.duration.inMilliseconds;
      if (dur == 0) return 0.0;
      return (_videoController!.value.position.inMilliseconds / dur).clamp(0.0, 1.0);
    }
    return _animController.value;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.profile.statuses[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: _isDragging ? .zero : const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        transform: Matrix4.translationValues(0, _dragY, 0)
          ..scale(
            (1.0 - (_dragY / MediaQuery.sizeOf(context).height * 0.7).clamp(0.0, 0.4)),
            (1.0 - (_dragY / MediaQuery.sizeOf(context).height * 0.7).clamp(0.0, 0.4)),
            1.0,
          ),
        child: Opacity(
          opacity: (1.0 - (_dragY / MediaQuery.sizeOf(context).height)).clamp(0.0, 1.0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onVerticalDragStart: _handleVerticalDragStart,
            onVerticalDragUpdate: _handleVerticalDragUpdate,
            onVerticalDragEnd: _handleVerticalDragEnd,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Media Content (Full Screen)
                if (item.type == StatusType.image)
                  CachedNetworkImage(
                    imageUrl: item.url,
                    fit: BoxFit.cover,
                    imageBuilder: (context, imageProvider) {
                      if (!_isMediaLoaded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => _onMediaLoaded());
                      }
                      return Image(image: imageProvider, fit: BoxFit.cover);
                    },
                    placeholder: (context, url) => _GradientCircleLoader(),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error_outline, color: Colors.white),
                    ),
                  )
                else if (item.type == StatusType.video &&
                    _videoController != null &&
                    _videoController!.value.isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                else
                  _GradientCircleLoader(),

                // Top Gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // UI Overlay (Safe Area)
                SafeArea(
                  child: Stack(
                    children: [
                      if (!_isPaused) ...[
                        // Top Progress Bar
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 10,
                          child: StatusProgressBar(
                            count: widget.profile.statuses.length,
                            currentIndex: _currentIndex,
                            activeProgress: _currentProgress,
                          ),
                        ),

                        // User Profile info
                        Positioned(
                          top: 24,
                          left: 10,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  widget.profile.profileUrl,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.profile.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Close Button
                        Positioned(
                          top: 10,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {}, // Prevent tap through
                            child: IconButton(
                              padding: .all(12),
                              constraints: .tightFor(width: 56, height: 56),
                              icon: const Icon(Icons.close, color: Colors.white, size: 28),
                              onPressed: () => _smoothClose(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}
}

class _GradientCircleLoader extends StatefulWidget {
  const _GradientCircleLoader({super.key});
  @override
  State<_GradientCircleLoader> createState() => _GradientCircleLoaderState();
}

class _GradientCircleLoaderState extends State<_GradientCircleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _controller,
        child: ShaderMask(
          shaderCallback: (rect) {
            return const SweepGradient(
              colors: [Color(0xFF0066FF), Color(0xFFE056FD), Color(0xFF0066FF)],
              stops: [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 3.5, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
