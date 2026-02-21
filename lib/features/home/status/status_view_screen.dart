import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'status_provider.dart';
import 'status_progress_bar.dart';

class StatusViewScreen extends StatefulWidget {
  final StatusProfile profile;
  final double pageOffset;
  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  const StatusViewScreen({
    super.key,
    required this.profile,
    required this.pageOffset,
    required this.onComplete,
    required this.onPrevious,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  bool _isPaused = false;

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

  void _loadStatus(int index) {
    _animController.stop();
    _animController.reset();

    final item = widget.profile.statuses[index];
    if (item.type == StatusType.video) {
      _loadVideo(item);
    } else {
      _loadImage(item);
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
      setState(() {});
      if (widget.pageOffset.abs() <= 0.01 && !_isPaused) {
        _videoController!.play();
      }
    }
  }

  void _loadImage(StatusItem item) {
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }
    _animController.duration = item.duration;
    if (mounted) {
      if (widget.pageOffset.abs() <= 0.01 && !_isPaused) {
        _animController.forward();
      }
    }
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
    setState(() {
      _isPaused = false;
    });

    final int duration = _tapDownTime != null
        ? DateTime.now().difference(_tapDownTime!).inMilliseconds
        : 0;

    if (duration < 250) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      if (details.globalPosition.dx < screenWidth / 3) {
        _prevStatus();
      } else {
        _nextStatus();
      }
    } else {
      if (widget.pageOffset.abs() <= 0.01) {
        _resumePlayback();
      }
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
    final item = widget.profile.statuses[_currentIndex];
    if (item.type == StatusType.video && _videoController != null) {
      if (!_videoController!.value.isInitialized) return 0.0;
      final dur = _videoController!.value.duration.inMilliseconds;
      if (dur == 0) return 0.0;
      return _videoController!.value.position.inMilliseconds / dur;
    }
    return _animController.value;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.profile.statuses[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Media Content
              if (item.type == StatusType.image)
                Image.network(
                  item.url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
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
                const Center(child: CircularProgressIndicator()),

              // Top Gradient for readability
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // UI Overlay
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
                        radius: 20,
                        backgroundImage: NetworkImage(
                          widget.profile.profileUrl,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Close Button
                Positioned(
                  top: 24,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
