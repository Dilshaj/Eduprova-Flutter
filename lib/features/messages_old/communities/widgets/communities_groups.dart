import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/community_model.dart';
import 'community_overview.dart';
import 'new_community_dialog.dart';

class CommunitiesGroupsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isEmbedded;
  final List<CommunityModel> communities;
  final Future<CommunityModel?> Function(String name, String description)?
  onCreateCommunity;
  final Future<void> Function()? onRefresh;

  const CommunitiesGroupsScreen({
    super.key,
    this.onBack,
    this.isEmbedded = false,
    required this.communities,
    this.onCreateCommunity,
    this.onRefresh,
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

  Future<void> _openCommunityOverview(CommunityModel community) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityOverviewScreen(
          communityId: community.id,
          initialCommunity: community,
        ),
      ),
    );

    if (changed == true) {
      await widget.onRefresh?.call();
    }
  }

  Future<void> _handleOpenCreateCommunity() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const NewCommunityDialog(),
    );

    if (result == null || widget.onCreateCommunity == null) return;

    final community = await widget.onCreateCommunity!(
      (result['name'] ?? '').toString(),
      (result['description'] ?? '').toString(),
    );

    if (!mounted || community == null) return;
    await _openCommunityOverview(community);
  }

  @override
  Widget build(BuildContext context) {
    final filteredCommunities = widget.communities.where((community) {
      return community.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search communities',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2563EB)),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onRefresh?.call(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                _buildNewCommunityRow(),
                const Divider(
                  height: 16,
                  thickness: 1,
                  color: Color(0xFFF3F4F6),
                  indent: 16,
                  endIndent: 16,
                ),
                if (filteredCommunities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No communities found.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ...filteredCommunities.map(_buildCommunitySection),
              ],
            ),
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

  Widget _buildCommunitySection(CommunityModel community) {
    final channels = List.of(community.groups);
    final communityId = community.id;
    final isExpanded = _expandedCommunities.contains(communityId);

    channels.sort((a, b) {
      final nameA = (a.name ?? '').toLowerCase();
      final nameB = (b.name ?? '').toLowerCase();
      bool isPriority(String name) =>
          name.contains('announcement') || name.contains('general');
      if (isPriority(nameA) && !isPriority(nameB)) return -1;
      if (!isPriority(nameA) && isPriority(nameB)) return 1;
      return 0;
    });

    final defaultChannels = channels.where((channel) {
      final name = (channel.name ?? '').toLowerCase();
      return name.contains('announcement') || name.contains('general');
    }).toList();
    final otherChannels = channels.where((channel) {
      final name = (channel.name ?? '').toLowerCase();
      return !name.contains('announcement') && !name.contains('general');
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _openCommunityOverview(community),
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
                  clipBehavior: Clip.antiAlias,
                  child: community.avatar != null && community.avatar!.isNotEmpty
                      ? Image.network(
                          community.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.groups_outlined,
                            color: Color(0xFF6B7280),
                            size: 24,
                          ),
                        )
                      : const Icon(
                          Icons.groups_outlined,
                          color: Color(0xFF6B7280),
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${community.memberCount} members',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ...defaultChannels.map(_buildChannelRow),
        if (isExpanded) ...otherChannels.map(_buildChannelRow),
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
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
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

  Widget _buildChannelRow(dynamic channel) {
    final name = channel.name ?? 'Unnamed group';
    final isAnnouncements = name.toLowerCase().contains('announcement');

    return InkWell(
      onTap: () => context.push('/chat/${channel.id}'),
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
              clipBehavior: Clip.antiAlias,
              child: channel.avatar != null && channel.avatar!.isNotEmpty
                  ? Image.network(
                      channel.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        isAnnouncements
                            ? Icons.campaign_outlined
                            : Icons.groups_outlined,
                        color: const Color(0xFF3B82F6),
                        size: 20,
                      ),
                    )
                  : Icon(
                      isAnnouncements
                          ? Icons.campaign_outlined
                          : Icons.groups_outlined,
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
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Open group chat',
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
