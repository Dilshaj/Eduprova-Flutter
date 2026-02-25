import 'package:flutter/material.dart';
import 'camera_verification.dart';
import 'audio_verification.dart';
import 'continue_button.dart';

class SecurityCheckScreen extends StatefulWidget {
  const SecurityCheckScreen({super.key});

  @override
  State<SecurityCheckScreen> createState() => _SecurityCheckScreenState();
}

class _SecurityCheckScreenState extends State<SecurityCheckScreen> {
  String _step = 'camera';
  bool _cameraActive = false;
  FaceStatus _faceStatus = FaceStatus.none;
  bool _cameraLocked = false;
  String? _capturedFaceUri;
  bool _audioVerified = false;
  double _audioLevel = 0.0;
  bool _cameraPermission = true; // Assumed granted for mock

  void _resetAll() {
    setState(() {
      _step = 'camera';
      _cameraActive = false;
      _faceStatus = FaceStatus.none;
      _cameraLocked = false;
      _capturedFaceUri = null;
      _audioVerified = false;
      _audioLevel = 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    _resetAll();
  }

  void _goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/courseContinue',
        arguments: {'targetSectionIndex': 2, 'targetLessonIndex': 1},
      );
    }
  }

  void _handleFaceStatusChange(FaceStatus status, [String? snapshot]) {
    if (_cameraLocked) return;
    setState(() {
      _faceStatus = status;
      if (status == FaceStatus.verified && snapshot != null) {
        _capturedFaceUri = snapshot;
      }
    });
  }

  void _handleStartCamera() {
    if (!_cameraPermission) {
      // simulate permission dialog
      setState(() => _cameraPermission = true);
    }
    setState(() {
      _cameraActive = true;
    });
  }

  void _handleNextToAudio() {
    setState(() {
      _cameraLocked = true;
      _step = 'audio';
    });
  }

  void _handleAudioVerified() {
    setState(() {
      _audioVerified = true;
    });
  }

  void _handleFinish(BuildContext context) {
    Navigator.pushNamed(context, '/finalAssessment');
  }

  Widget _renderStepProgress() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step 1
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _cameraLocked
                      ? const Color(0xFF22C55E)
                      : (_cameraActive
                            ? const Color(0xFF0066FF)
                            : const Color(0xFFE5E7EB)),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _cameraLocked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                'Camera',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: (_cameraActive || _cameraLocked)
                      ? FontWeight.bold
                      : FontWeight.w600,
                  color: (_cameraActive || _cameraLocked)
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          // Connector
          Container(
            width: 44,
            height: 2,
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
            ).copyWith(bottom: 14),
            decoration: BoxDecoration(
              color: _cameraLocked
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          // Step 2
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _step == 'audio'
                      ? (_audioVerified
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF0066FF))
                      : const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _audioVerified
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                'Audio',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: _step == 'audio'
                      ? FontWeight.bold
                      : FontWeight.w600,
                  color: _step == 'audio'
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 4),
                child: Text(
                  'Security Check',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: Text(
                  'IDENTITY VERIFICATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              _renderStepProgress(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _step == 'camera'
                                  ? 'Camera Check'
                                  : 'Microphone Check',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF374151),
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),

                            if (_step == 'camera')
                              CameraVerification(
                                cameraPermission: _cameraPermission,
                                onRequestPermission: () =>
                                    setState(() => _cameraPermission = true),
                                faceStatus: _faceStatus,
                                onFaceStatusChange: _handleFaceStatusChange,
                                cameraActive: _cameraActive,
                                onStartCamera: _handleStartCamera,
                                locked: _cameraLocked,
                                capturedFaceUri: _capturedFaceUri,
                              )
                            else
                              Column(
                                children: [
                                  if (_capturedFaceUri != null)
                                    Container(
                                      margin: const EdgeInsets.only(
                                        bottom: 14,
                                        top: 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFF22C55E,
                                                    ),
                                                    width: 2,
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Container(
                                                  width: 34,
                                                  height: 34,
                                                  decoration:
                                                      const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(
                                                          0xFFE5E7EB,
                                                        ),
                                                      ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  ), // Mock Image
                                                ),
                                              ),
                                              const Positioned(
                                                bottom: -2,
                                                right: -2,
                                                child: Icon(
                                                  Icons.check_circle,
                                                  size: 14,
                                                  color: Color(0xFF22C55E),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'Identity confirmed',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF22C55E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  AudioVerification(
                                    isActive: _step == 'audio',
                                    audioVerified: _audioVerified,
                                    onAudioVerified: _handleAudioVerified,
                                    audioLevel: _audioLevel,
                                    onAudioLevelChange: (lvl) =>
                                        setState(() => _audioLevel = lvl),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Info Box
                      Container(
                        margin: const EdgeInsets.only(top: 14, bottom: 20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: Color(0xFF0066FF),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Camera and microphone remain active during the exam to ensure integrity.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF374151),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Bar
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                padding: const EdgeInsets.only(top: 8),
                child: ContinueButton(
                  step: _step,
                  faceStatus: _faceStatus,
                  cameraLocked: _cameraLocked,
                  audioVerified: _audioVerified,
                  onNext: _handleNextToAudio,
                  onFinish: () => _handleFinish(context),
                  paddingBottom: MediaQuery.of(context).padding.bottom + 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
