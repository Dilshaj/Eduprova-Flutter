import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new_community_dialog.dart';
import 'community_overview.dart';

class CommunitiesGroupsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isEmbedded;
  final List<Map<String, dynamic>> communities;
  final Function(Map<String, dynamic>) onAddNewCommunity;
  final Function(String, List<Map<String, dynamic>>) onUpdateGroups;

  const CommunitiesGroupsScreen({
    super.key,
    this.onBack,
    this.isEmbedded = false,
    required this.communities,
    required this.onAddNewCommunity,
    required this.onUpdateGroups,
  });

  @override
  State<CommunitiesGroupsScreen> createState() =>
      _CommunitiesGroupsScreenState();
}

class _CommunitiesGroupsScreenState extends State<CommunitiesGroupsScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _searchQuery = '';
  final Set<String> _expandedCommunities = {};

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleOpenCreateCommunity() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const NewCommunityDialog(),
    );

    if (result != null) {
      final newCommunity = {
        'id': 'comm_${DateTime.now().millisecondsSinceEpoch}',
        'name': result['name'],
        'description': result['description'],
        'members': '0 members',
        'type': 'new',
        'icon': Icons.groups_outlined,
        'channels': [
          {'id': 'c1', 'name': 'Announcements', 'type': 'broadcast'},
          {'id': 'c2', 'name': 'General', 'type': 'discussion'},
        ],
      };
      widget.onAddNewCommunity(newCommunity);
      
      // Navigate to overview after creation
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityOverviewScreen(
              community: newCommunity,
              onGroupsUpdated: (updatedChannels) {
                widget.onUpdateGroups(newCommunity['id'] as String, updatedChannels);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    final filteredCommunities = widget.communities.where((c) {
      return (c['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [

        const SizedBox(height: 4),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              // New Community Row
              _buildNewCommunityRow(),
              
              const Divider(height: 16, thickness: 1, color: Color(0xFFF3F4F6), indent: 16, endIndent: 16),

              // Community List
              ...filteredCommunities.map((community) => _buildCommunitySection(community)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewCommunityRow() {
    return InkWell(
      onTap: _handleOpenCreateCommunity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.group_add, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              'New community',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitySection(Map<String, dynamic> community) {
    final channels = community['channels'] as List<dynamic>? ?? [];
    final communityId = community['id'] as String;
    final isExpanded = _expandedCommunities.contains(communityId);
    
    // Sort channels so Announcements and General are always first if they exist
    final sortedChannels = List.from(channels);
    sortedChannels.sort((a, b) {
      final nameA = (a['name'] as String).toLowerCase();
      final nameB = (b['name'] as String).toLowerCase();
      
      bool isPriority(String name) => name.contains('announcement') || name.contains('general');
      
      if (isPriority(nameA) && !isPriority(nameB)) return -1;
      if (!isPriority(nameA) && isPriority(nameB)) return 1;
      return 0;
    });

    final defaultChannels = sortedChannels.where((c) {
      final name = (c['name'] as String).toLowerCase();
      return name.contains('announcement') || name.contains('general');
    }).toList();

    final otherChannels = sortedChannels.where((c) {
      final name = (c['name'] as String).toLowerCase();
      return !name.contains('announcement') && !name.contains('general');
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Community Header
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommunityOverviewScreen(
                  community: community,
                  onGroupsUpdated: (updatedChannels) {
                    widget.onUpdateGroups(community['id'] as String, updatedChannels);
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    community['icon'] as IconData? ?? Icons.groups_outlined,
                    color: const Color(0xFF6B7280),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    community['name'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Default Channel Rows (Always Visible)
        ...defaultChannels.map((channel) => _buildChannelRow(community, channel)),
        
        // Conditional Other Channel Rows
        if (isExpanded)
          ...otherChannels.map((channel) => _buildChannelRow(community, channel)),

        // View More / Show Less Button
        if (otherChannels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 68, top: 4, bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedCommunities.remove(communityId);
                  } else {
                    _expandedCommunities.add(communityId);
                  }
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? 'Show less' : 'View more',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16,
                    color: const Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
          ),
        
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildChannelRow(Map<String, dynamic> community, dynamic channel) {
    final name = channel['name'] as String;
    final isAnnouncements = name.toLowerCase().contains('announcement');
    
    return InkWell(
      onTap: () {
        // Chat room navigation would go here
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const SizedBox(width: 6),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isAnnouncements ? Icons.campaign_outlined : Icons.groups_outlined,
                color: const Color(0xFF3B82F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.substring(0, 1).toUpperCase() + name.substring(1),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'No messages yet',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
