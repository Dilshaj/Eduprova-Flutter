import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/messages_background.dart';
import '../../widgets/messages_button.dart';

class ActivityData {
  final String id;
  final bool isHeader;
  final String title;
  final String? type;
  final String? subtitle;
  final String? time;
  final IconData? icon;
  final Color? iconColor;
  final Color? bg;
  final String? avatar;
  final bool actions;
  final String? actionLink;
  final String? secondaryLink;
  final bool isOnline;
  final Map<String, String>? attachment;

  ActivityData({
    required this.id,
    this.isHeader = false,
    required this.title,
    this.type,
    this.subtitle,
    this.time,
    this.icon,
    this.iconColor,
    this.bg,
    this.avatar,
    this.actions = false,
    this.actionLink,
    this.secondaryLink,
    this.isOnline = false,
    this.attachment,
  });
}

final List<ActivityData> activityDataList = [
  ActivityData(
    id: '1',
    type: 'meeting',
    title: 'Meeting starting in 5 mins',
    subtitle: 'Weekly Design Sync - General Channel',
    time: 'Just now',
    icon: Icons.videocam,
    iconColor: const Color(0xFFF97316),
    bg: const Color(0xFFFFF7ED),
    actions: true,
  ),
  ActivityData(
    id: '2',
    type: 'message',
    title: 'New message from Rose Nguyen',
    subtitle: '"I\'ve updated the Figma mockups with the new gradient theme as we discussed..."',
    time: '12m ago',
    avatar: 'https://i.pravatar.cc/300?u=10',
    actionLink: 'Reply',
    secondaryLink: 'Mark as read',
    isOnline: true,
  ),
  ActivityData(
    id: '3',
    type: 'file',
    title: 'Varaha shared a file',
    time: '45m ago',
    icon: Icons.insert_drive_file,
    iconColor: const Color(0xFF0066FF),
    bg: const Color(0xFFEFF6FF),
    attachment: {
      'name': 'MacBook Pro 16_mockup.png',
      'size': '2.4 MB • Image',
      'icon': 'image',
    },
  ),
  ActivityData(
    id: 'header',
    isHeader: true,
    title: 'YESTERDAY',
  ),
  ActivityData(
    id: '4',
    type: 'mention',
    title: 'You were mentioned in Design Enthusiasts',
    subtitle: 'Bharat: "@Jane what do you think about the new onboarding flow?"',
    time: '22h ago',
    icon: Icons.alternate_email,
    iconColor: const Color(0xFF9333EA),
    bg: const Color(0xFFF3E8FF),
    actionLink: 'View in Community',
  ),
  ActivityData(
    id: '5',
    type: 'task',
    title: 'Task completed: Platform Review',
    subtitle: 'Review of the architecture proposal has been marked as finished by Ganesh.',
    time: '1d ago',
    icon: Icons.check_circle,
    iconColor: const Color(0xFF059669),
    bg: const Color(0xFFECFDF5),
  ),
];

class ActivityScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isEmbedded;
  const ActivityScreen({super.key, this.onBack, this.isEmbedded = false});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      if (widget.isEmbedded) {
        return const Center(child: CircularProgressIndicator());
      }
      return const MessagesBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
        
      );
    }

    if (widget.isEmbedded) {
      return _buildBody(context);
    }
    
    return MessagesBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: _buildBody(context)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const paddingX = 20.0;
    
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (!widget.isEmbedded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.onBack != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: isDarkMode ? Colors.white : const Color(0xFF111111),
                          ),
                          onPressed: widget.onBack,
                        ),
                      ),
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'JM',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? const Color(0xFFD1FAE5) : const Color(0xFF065F46),
                        ),
                      ),
                    ),
                    Text(
                      'Activity',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: paddingX, vertical: 12),
              child: Text(
                'TODAY',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF9CA3AF),
                  letterSpacing: 1.0,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: paddingX, right: paddingX, bottom: 100),
                itemCount: activityDataList.length,
                itemBuilder: (context, index) {
                  final item = activityDataList[index];

                  if (item.isHeader) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 12),
                      child: Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9CA3AF),
                          letterSpacing: 1.0,
                        ),
                      ),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black26 : Colors.white70,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode ? Colors.white10 : Colors.white24,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon or Avatar
                        if (item.avatar != null)
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(item.avatar!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: item.bg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(item.icon, size: 24, color: item.iconColor),
                          ),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : const Color(0xFF111111),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.time ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle!,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    fontStyle: item.type == 'message' ? FontStyle.italic : FontStyle.normal,
                                  ),
                                ),
                              ],

                              // Actions
                              if (item.actions) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    MessagesButton(
                                      text: 'Join Now',
                                      height: 36,
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Dismiss',
                                        style: GoogleFonts.inter(
                                          color: isDarkMode ? const Color(0xFFE5E7EB) : const Color(0xFF4B5563),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // Attachment Box
                              if (item.attachment != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: isDarkMode ? const Color(0xFF374151) : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.image,
                                          size: 20,
                                          color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.attachment!['name']!,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode ? Colors.white : const Color(0xFF111111),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.attachment!['size']!,
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.download_outlined,
                                        size: 20,
                                        color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Links
                              if (item.actionLink != null || item.secondaryLink != null) ...[
                                SizedBox(height: item.subtitle != null ? 12 : 0),
                                Row(
                                  children: [
                                    if (item.type == 'message')
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF10B981),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (item.actionLink != null)
                                      Text(
                                        item.actionLink!,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF0066FF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if (item.secondaryLink != null) ...[
                                      const SizedBox(width: 16),
                                      Text(
                                        item.secondaryLink!,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF9CA3AF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // FAB
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6674FF).withValues(alpha: 0.4),
                  offset: const Offset(0, 8),
                  blurRadius: 10,
                ),
              ],
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(28),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
