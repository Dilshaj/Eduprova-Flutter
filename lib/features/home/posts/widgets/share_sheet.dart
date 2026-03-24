import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';

class ShareSheet extends StatelessWidget {
  final String postId;
  final String content;

  const ShareSheet({
    super.key,
    required this.postId,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1F2937) : Colors.white;

    final shareOptions = [
      {'icon': LucideIcons.link, 'label': 'Copy Link', 'color': const Color(0xFF3B82F6)},
      {'icon': LucideIcons.twitter, 'label': 'Twitter', 'color': const Color(0xFF1DA1F2)},
      {'icon': LucideIcons.facebook, 'label': 'Facebook', 'color': const Color(0xFF1877F2)},
      {'icon': LucideIcons.instagram, 'label': 'Instagram', 'color': const Color(0xFFE4405F)},
      {'icon': LucideIcons.send, 'label': 'WhatsApp', 'color': const Color(0xFF25D366)},
      {'icon': LucideIcons.mail, 'label': 'Email', 'color': const Color(0xFF64748B)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Share Post',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shareOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final option = shareOptions[index];
                return GestureDetector(
                  onTap: () {
                    if (option['label'] == 'Copy Link') {
                      Clipboard.setData(ClipboardData(text: 'https://eduprova.com/post/$postId'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: (option['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          option['icon'] as IconData,
                          color: option['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
