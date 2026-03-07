import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
import '../interview_bot/interview_bot_screen.dart';
import 'ai_theme.dart';
import '../core/repositories/interview_repository.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
  bool _isUploading = false;
  PlatformFile? _selectedFile;

  final TextEditingController _jobRoleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();

  String _selectedDuration = '30M';
  String _selectedVoice = 'FEM';

  Future<void> _pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _startInterview() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your resume first')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final repo = InterviewRepository();
      final result = await repo.createSession(
        type: 'resume',
        config: {
          'jobRole': _jobRoleController.text,
          'jobDescription': _jobDescriptionController.text,
          'resumeName': _selectedFile!.name,
          'duration': _selectedDuration == '30M' ? 30 : 60,
          'voice': _selectedVoice.toLowerCase(),
        },
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InterviewBotPage(
              sessionId: result.sessionId,
              questions: result.questions,
              role: _jobRoleController.text.isNotEmpty
                  ? _jobRoleController.text
                  : 'Resume Based',
              duration: _selectedDuration,
              voice: _selectedVoice == 'FEM' ? 'FEMALE' : 'MALE',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Stack(
        children: [
          const BlurredBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _buildUploadChip(),
                          const SizedBox(height: 24),
                          _buildTitles(),
                          const SizedBox(height: 16),
                          _buildSubtitles(),
                          const SizedBox(height: 32),
                          _buildFormCard(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: t.iconBack, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: t.iconBack,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildUploadChip() {
    final t = AiTheme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: t.chipBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.chipBorder, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'RESUME ANALYSIS ACTIVE',
                style: TextStyle(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitles() {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Targeted',
            style: TextStyle(
              color: t.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Interview Prep',
            style: TextStyle(
              color: const Color(0xFF3B82F6),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitles() {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Upload your resume and we\'ll tailor questions specifically to your background and target role.',
        style: TextStyle(
          color: t.textMuted,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: t.cardBorder, width: 1),
          boxShadow: t.cardShadow,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.upload_file_rounded, 'UPLOAD RESUME'),
            const SizedBox(height: 16),
            _buildUploadArea(),
            const SizedBox(height: 32),
            _buildSectionHeader(Icons.work_outline_rounded, 'TARGET ROLE'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _jobRoleController,
              hint: 'e.g. Senior Frontend Engineer',
              icon: Icons.person_search_outlined,
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(Icons.tune_rounded, 'PREFERENCES'),
            const SizedBox(height: 16),
            _buildPreferencesRows(),
            const SizedBox(height: 32),
            _buildSectionHeader(
              Icons.description_outlined,
              'JOB DESCRIPTION (OPTIONAL)',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _jobDescriptionController,
              hint: 'Paste the job description here...',
              icon: Icons.notes_rounded,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    final t = AiTheme.of(context);
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3B82F6), size: 18),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: t.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    final t = AiTheme.of(context);
    final isSelected = _selectedFile != null;

    return GestureDetector(
      onTap: _pickResume,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withValues(alpha: 0.05)
              : t.scaffoldBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : t.cardBorder.withValues(alpha: 0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.cloud_upload_outlined,
              color: isSelected ? const Color(0xFF3B82F6) : t.textMuted,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              isSelected
                  ? _selectedFile!.name
                  : 'Drop your resume or click to browse',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? t.textPrimary : t.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (!isSelected) ...[
              const SizedBox(height: 4),
              Text(
                'PDF, DOCX up to 10MB',
                style: TextStyle(color: t.textMuted, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesRows() {
    return Row(
      children: [
        Expanded(child: _buildToggleOption('DUR', 'Duration')),
        const SizedBox(width: 16),
        Expanded(child: _buildToggleOption('VOI', 'Voice')),
      ],
    );
  }

  Widget _buildToggleOption(String type, String label) {
    final t = AiTheme.of(context);
    final isDur = type == 'DUR';
    final options = isDur ? ['30M', '60M'] : ['ML', 'FL'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: t.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: t.scaffoldBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: options.map((opt) {
              final isSelected = isDur
                  ? _selectedDuration == opt
                  : _selectedVoice == (opt == 'ML' ? 'MAL' : 'FEM');
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isDur) {
                        _selectedDuration = opt;
                      } else {
                        _selectedVoice = opt == 'ML' ? 'MAL' : 'FEM';
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? t.cardBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected ? t.cardShadow : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : t.textMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    final t = AiTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.scaffoldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.cardBorder.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: t.textMuted.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: t.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _isUploading ? null : _startInterview,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: const Color(0xFF3B82F6).withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isUploading
              ? const SpinKitThreeBounce(color: Colors.white, size: 24)
              : const Text(
                  'ANALYZE & START',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
        ),
      ),
    );
  }
}

class BlurredBackground extends StatelessWidget {
  const BlurredBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        return Stack(
          children: [
            Positioned(
              top: height * 0.1,
              right: -width * 0.2,
              child: Container(
                width: width * 0.8,
                height: width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.2,
              left: -width * 0.2,
              child: Container(
                width: width * 0.8,
                height: width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}
