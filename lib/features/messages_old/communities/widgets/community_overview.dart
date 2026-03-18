import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityOverviewScreen extends StatefulWidget {
  final Map<String, dynamic> community;
  final Function(List<Map<String, dynamic>>) onGroupsUpdated;

  const CommunityOverviewScreen({
    super.key, 
    required this.community,
    required this.onGroupsUpdated,
  });

  @override
  State<CommunityOverviewScreen> createState() => _CommunityOverviewScreenState();
}

class _CommunityOverviewScreenState extends State<CommunityOverviewScreen> {
  late List<Map<String, dynamic>> _channels;

  @override
  void initState() {
    super.initState();
    _channels = List.from(widget.community['channels'] ?? []);
    if (_channels.isEmpty) {
      _channels = [
        {
          'icon': Icons.campaign_outlined,
          'title': 'Announcements',
          'badge': 'Broadcast',
          'subtitle': 'Official updates and news from the admins',
        },
        {
          'icon': Icons.groups_outlined,
          'title': 'General',
          'badge': 'Discussion',
          'subtitle': 'Standard community channel',
        },
      ];
    } else {
      // Map existing channel data forward to our expected format
      _channels = _channels.map((c) {
        final name = c['name'] as String;
        final isAnnouncements = name.toLowerCase().contains('announcement');
        return {
          'icon': isAnnouncements ? Icons.campaign_outlined : Icons.groups_outlined,
          'title': name.substring(0, 1).toUpperCase() + name.substring(1),
          'badge': isAnnouncements ? 'Broadcast' : 'Discussion',
          'subtitle': isAnnouncements 
              ? 'Official updates and news from the admins' 
              : 'Standard community channel',
        };
      }).toList();
    }
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Create New Group',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Group name',
            hintStyle: GoogleFonts.inter(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.grey),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _channels.add({
                    'icon': Icons.groups_outlined,
                    'title': nameController.text.trim(),
                    'badge': 'Discussion',
                    'subtitle': 'New community group',
                  });
                });
                
                // Notify parent about the new group
                final updatedChannelsForParent = _channels.map((c) {
                  return {
                    'id': 'c_new_${DateTime.now().millisecondsSinceEpoch}',
                    'name': c['title'],
                  };
                }).toList();
                widget.onGroupsUpdated(updatedChannelsForParent);
                
                Navigator.pop(ctx);
              }
            },
            child: Text(
              'CREATE',
              style: GoogleFonts.inter(
                color: const Color(0xFF0066FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ElevatedButton(
              onPressed: _showCreateGroupDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Create Group',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Info Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.groups_outlined, color: Colors.white, size: 32),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${_channels.length}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0066FF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.community['name'],
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'COMMUNITY',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${_channels.length} groups',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\"${widget.community['description'] ?? 'No description'}\"",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF374151),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tag, size: 20, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 8),
                      Text(
                        'Community Channels',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 4),
                        Text(
                          'Add existing',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Channel List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: _channels.map((channel) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildChannelItem(
                      icon: channel['icon'],
                      title: channel['title'],
                      badge: channel['badge'],
                      subtitle: channel['subtitle'],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelItem({
    required IconData icon,
    required String title,
    required String badge,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0EA5E9), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        ],
      ),
    );
  }
}
