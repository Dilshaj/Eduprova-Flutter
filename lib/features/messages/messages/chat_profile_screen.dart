import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatProfileScreen extends StatelessWidget {
  final String id;
  const ChatProfileScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      // We can achieve gradient border via shader masks,
                      // but simplified here for stable UI
                      color: Colors.purple.shade200,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        // color: AppTheme.purpleBlob,
                        color: Colors.purple,
                      ),
                      child: Center(
                        child: Text(
                          'VL',
                          style: TextStyle(
                            color: Colors.purple.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Varahanarasimha Logisa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Senior Product Designer',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(context, Icons.call_outlined, 'Audio'),
                const SizedBox(width: 20),
                _buildActionButton(context, Icons.videocam_outlined, 'Video'),
                const SizedBox(width: 20),
                _buildActionButton(context, Icons.search, 'Search'),
                const SizedBox(width: 20),
                _buildActionButton(
                  context,
                  Icons.auto_awesome_outlined,
                  'Themes',
                  isActive: true,
                ),
                const SizedBox(width: 20),
                _buildActionButton(context, Icons.volume_off_outlined, 'Mute'),
              ],
            ),

            const SizedBox(height: 32),

            // Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard(
                    context,
                    Icons.call_outlined,
                    'PHONE NUMBER',
                    '+1 (555) 012-3456',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    Icons.alternate_email,
                    'EMAIL',
                    'varahanarasimha@design.co',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Shared Media Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SHARED MEDIA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'See All >',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMediaThumbnail(Colors.purple),
                      _buildMediaThumbnail(Colors.indigo),
                      _buildMediaThumbnail(Colors.pink),
                      _buildMediaMoreCount('+24'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Red action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildDangerAction(context, Icons.block, 'Block Contact'),
                  const SizedBox(height: 16),
                  _buildDangerAction(
                    context,
                    Icons.warning_amber_rounded,
                    'Report Contact',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label, {
    bool isActive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey.shade200;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.withValues(alpha: 0.1) : cardBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? Colors.blue.withValues(alpha: 0.3)
                  : borderColor,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.blue.shade600 : subTextColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue.shade600 : subTextColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey.shade500;
    final iconBgColor = isDark
        ? const Color.fromRGBO(251, 252, 255, 0.05)
        : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.indigo.shade400, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: subTextColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaThumbnail(Color color) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildMediaMoreCount(String count) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDangerAction(BuildContext context, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red.shade400, size: 22),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
