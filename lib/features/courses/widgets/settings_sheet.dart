import 'package:flutter/material.dart';

class SettingsSheet extends StatelessWidget {
  final bool visible;
  final VoidCallback onClose;
  final String currentQuality;
  final ValueChanged<String> onQualityChange;
  final double currentSpeed;
  final ValueChanged<double> onSpeedChange;

  const SettingsSheet({
    super.key,
    required this.visible,
    required this.onClose,
    required this.currentQuality,
    required this.onQualityChange,
    required this.currentSpeed,
    required this.onSpeedChange,
  });

  static const List<String> qualities = ['1080p', '720p', '480p'];
  static const List<double> speeds = [0.5, 1.0, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap:
                  () {}, // empty tap to prevent closing when pressing bottom sheet area
              child: TweenAnimationBuilder(
                tween: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                builder: (context, Offset offset, child) {
                  return FractionalTranslation(
                    translation: offset,
                    child: child,
                  );
                },
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Playback Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          InkWell(
                            onTap: onClose,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 24,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Divider(
                        color: Color(0xFFF0F0F0),
                        height: 1,
                        thickness: 1,
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                Icons.settings_outlined,
                                'Quality',
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: qualities
                                    .map(
                                      (q) => _buildOptionButton(
                                        label: q,
                                        isActive: currentQuality == q,
                                        onTap: () => onQualityChange(q),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Divider(
                                  color: Color(0xFFF0F0F0),
                                  height: 1,
                                  thickness: 1,
                                ),
                              ),
                              _buildSectionTitle(
                                Icons.speed_outlined,
                                'Playback Speed',
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: speeds
                                    .map(
                                      (s) => _buildOptionButton(
                                        label: '${s}x',
                                        isActive: currentSpeed == s,
                                        onTap: () => onSpeedChange(s),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Divider(
                                  color: Color(0xFFF0F0F0),
                                  height: 1,
                                  thickness: 1,
                                ),
                              ),
                              _buildSectionTitle(
                                Icons.language_outlined,
                                'Audio',
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: ['English', 'Spanish', 'French']
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      int idx = entry.key;
                                      String lang = entry.value;
                                      return _buildOptionButton(
                                        label: lang,
                                        isActive: idx == 0,
                                        onTap: () {},
                                      );
                                    })
                                    .toList(),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Divider(
                                  color: Color(0xFFF0F0F0),
                                  height: 1,
                                  thickness: 1,
                                ),
                              ),
                              _buildSectionTitle(
                                Icons.text_format_outlined,
                                'Captions',
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'English (Auto-generated) - Coming Soon',
                                  style: TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF333333)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF6FF) : const Color(0xFFF5F5F5),
          border: Border.all(
            color: isActive ? const Color(0xFF0066FF) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? const Color(0xFF0066FF) : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}
