import 'package:edupurva/core/navigation/app_routes.dart';
import 'package:edupurva/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommunitiesView extends StatefulWidget {
  const CommunitiesView({super.key});

  @override
  State<CommunitiesView> createState() => _CommunitiesViewState();
}

class _CommunitiesViewState extends State<CommunitiesView> {
  int? _expandedIndex = 0; // First card expanded by default

  final List<_CommunityData> _communities = [
    _CommunityData(
      name: 'School Group',
      members: '12.4k Students',
      icon: Icons.menu_book_rounded,
      iconBg: const Color(0xFFE8EEF8),
      iconColor: const Color(0xFF3B6BCC),
      channels: ['general', 'resources', 'collaboration'],
    ),
    _CommunityData(
      name: 'Design Lead Circle',
      members: '4.2k members',
      icon: Icons.view_in_ar_rounded,
      iconBg: const Color(0xFFFDE8E8),
      iconColor: const Color(0xFFD94F4F),
      channels: ['design-review', 'inspiration', 'feedback'],
    ),
    _CommunityData(
      name: 'Dev Collective',
      members: '8.5k developers',
      icon: Icons.code_rounded,
      iconBg: const Color(0xFFE0F5E8),
      iconColor: const Color(0xFF3BA55D),
      channels: ['frontend', 'backend', 'devops'],
    ),
    _CommunityData(
      name: 'Photography Hub',
      members: '3.1k creatives',
      icon: Icons.camera_alt_rounded,
      iconBg: const Color(0xFFF3E8FD),
      iconColor: const Color(0xFF9B59B6),
      channels: ['showcase', 'tips', 'editing'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
        Colors.grey;
    final cardBg = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COMMUNITIES',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 1.5,
                ),
              ),
              Row(
                children: [
                  _buildHeaderIcon(
                    Icons.search_rounded,
                    subTextColor,
                    borderColor,
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => context.push(AppRoutes.createCommunity),
                    borderRadius: BorderRadius.circular(20),
                    child: _buildHeaderIcon(
                      Icons.add_rounded,
                      subTextColor,
                      borderColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Communities list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _communities.length,
            itemBuilder: (context, index) {
              final community = _communities[index];
              final isExpanded = _expandedIndex == index;
              return _buildCommunityCard(
                context,
                community,
                index,
                isExpanded,
                cardBg,
                borderColor,
                textColor,
                subTextColor,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon, Color color, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildCommunityCard(
    BuildContext context,
    _CommunityData community,
    int index,
    bool isExpanded,
    Color? cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Community icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: community.iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      community.icon,
                      color: community.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          community.members,
                          style: TextStyle(fontSize: 13, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: subTextColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded channels
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildChannelList(
              community.channels,
              textColor,
              subTextColor,
              borderColor,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelList(
    List<String> channels,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final channelBg = isDark ? Colors.grey[800]! : const Color(0xFFF4F6F9);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          ...channels.asMap().entries.map((entry) {
            final channelName = entry.value;
            final isFirst = entry.key == 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFirst ? channelBg : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    '#',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isFirst ? const Color(0xFF3B6BCC) : subTextColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      channelName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isFirst
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: textColor,
                      ),
                    ),
                  ),
                  Icon(Icons.more_vert, color: subTextColor, size: 18),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // New Channel button
          InkWell(
            onTap: () => context.push(AppRoutes.createChannel),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => kGradient.createShader(bounds),
                    child: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'NEW CHANNEL',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: subTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityData {
  final String name;
  final String members;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final List<String> channels;

  _CommunityData({
    required this.name,
    required this.members,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.channels,
  });
}
