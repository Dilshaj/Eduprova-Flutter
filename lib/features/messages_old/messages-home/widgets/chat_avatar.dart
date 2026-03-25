import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/image_cache_manager.dart';
import '../../models/conversation_model.dart';

class ChatAvatar extends StatelessWidget {
  final ConversationModel? conversation;
  final String? currentUserId;
  final double size;

  const ChatAvatar({
    super.key,
    this.conversation,
    this.currentUserId,
    this.size = 56,
  });

  static const _avatarColors = [
    // Background, Foreground
    [Color(0xFFE2E8F0), Color(0xFF1E293B)], // Gray/Slate
    [Color(0xFFD1FAE5), Color(0xFF065F46)], // Green
    [Color(0xFFEDE9FE), Color(0xFF5B21B6)], // Purple
    [Color(0xFFFFEDD5), Color(0xFF9A3412)], // Orange
    [Color(0xFFDBEAFE), Color(0xFF1E40AF)], // Blue
    [Color(0xFFFCE7F3), Color(0xFF9D174D)], // Pink
    [Color(0xFFFEF3C7), Color(0xFF92400E)], // Yellow/Amber
    [Color(0xFFFEE2E2), Color(0xFF991B1B)], // Red
  ];

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  Color _getBackgroundColor(String id) {
    if (id.isEmpty) return _avatarColors[0][0];
    final hash = id.hashCode.abs();
    return _avatarColors[hash % _avatarColors.length][0];
  }

  Color _getForegroundColor(String id) {
    if (id.isEmpty) return _avatarColors[0][1];
    final hash = id.hashCode.abs();
    return _avatarColors[hash % _avatarColors.length][1];
  }

  Widget? _buildStatusBadge(BuildContext context, String id) {
    if (conversation == null) return null;
    if (conversation!.type != ConversationType.direct) return null;

    final hash = id.hashCode.abs();
    final statusType = hash % 5;

    if (statusType == 3) return null;

    final badgeSize = size * 0.35;
    final innerIconSize = badgeSize * 0.6;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final strokeColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    Widget statusIcon;
    Color bgColor;

    switch (statusType) {
      case 0:
      case 4:
        bgColor = const Color(0xFF22C55E);
        statusIcon = Icon(
          Icons.check,
          size: innerIconSize,
          color: Colors.white,
        );
        break;
      case 1:
        bgColor = const Color(0xFFEF4444);
        statusIcon = const SizedBox();
        break;
      case 2:
      default:
        bgColor = const Color(0xFFF59E0B);
        statusIcon = Icon(
          Icons.access_time,
          size: innerIconSize,
          color: Colors.white,
        );
        break;
    }

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: strokeColor, width: 2.5),
      ),
      alignment: Alignment.center,
      child: statusIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (conversation == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
      );
    }

    final avatar = conversation!.getDisplayAvatar(currentUserId ?? '');
    final title = conversation!.getDisplayTitle(currentUserId ?? '');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? const Color(0xFF374151)
        : const Color(0xFFE5E7EB);

    // Primary ID to use for hashing (user ID for direct chats, conversation ID otherwise)
    final hashId = conversation!.type == ConversationType.direct
        ? (conversation!.participants
              .firstWhere(
                (p) => p.userId != currentUserId,
                orElse: () => conversation!.participants.first,
              )
              .userId)
        : conversation!.id;

    Widget avatarWidget;

    if (avatar != null && avatar.isNotEmpty) {
      avatarWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatar,
            cacheManager: CacheManagers.messageCacheManager,
            placeholder: (context, url) =>
                Container(color: Colors.grey.withValues(alpha: 0.1)),
            errorWidget: (context, url, error) =>
                _buildInitialsAvatar(hashId, title),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (conversation!.type != ConversationType.direct) {
      avatarWidget = _buildGroupAvatar(context, hashId);
    } else {
      avatarWidget = _buildInitialsAvatar(hashId, title);
    }

    final statusBadge = _buildStatusBadge(context, hashId);

    if (statusBadge == null) {
      return avatarWidget;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            right: -size * 0.05,
            bottom: -size * 0.05,
            child: statusBadge,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAvatar(BuildContext context, String hashId) {
    final otherParticipants = conversation!.participants
        .where((p) => p.userId != currentUserId)
        .toList();

    if (otherParticipants.isEmpty) {
      otherParticipants.addAll(conversation!.participants);
    }

    if (otherParticipants.length == 1) {
      return _buildInitialsAvatar(hashId, conversation!.name ?? 'Group');
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    Widget gridWidget;

    if (otherParticipants.length == 2) {
      gridWidget = Row(
        children: [
          Expanded(
            child: _buildParticipantGridItem(
              context,
              otherParticipants[0],
              size,
            ),
          ),
          Container(width: 1.5, color: dividerColor),
          Expanded(
            child: _buildParticipantGridItem(
              context,
              otherParticipants[1],
              size,
            ),
          ),
        ],
      );
    } else if (otherParticipants.length == 3) {
      gridWidget = Row(
        children: [
          Expanded(
            child: _buildParticipantGridItem(
              context,
              otherParticipants[0],
              size,
            ),
          ),
          Container(width: 1.5, color: dividerColor),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildParticipantGridItem(
                    context,
                    otherParticipants[1],
                    size,
                  ),
                ),
                Container(height: 1.5, color: dividerColor),
                Expanded(
                  child: _buildParticipantGridItem(
                    context,
                    otherParticipants[2],
                    size,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      gridWidget = Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildParticipantGridItem(
                    context,
                    otherParticipants[0],
                    size,
                  ),
                ),
                Container(height: 1.5, color: dividerColor),
                Expanded(
                  child: _buildParticipantGridItem(
                    context,
                    otherParticipants[2],
                    size,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1.5, color: dividerColor),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildParticipantGridItem(
                    context,
                    otherParticipants[1],
                    size,
                  ),
                ),
                Container(height: 1.5, color: dividerColor),
                Expanded(
                  child: _buildParticipantGridItem(
                    context,
                    otherParticipants[3],
                    size,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final borderColor = isDarkMode
        ? const Color(0xFF374151)
        : const Color(0xFFE5E7EB);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: ClipOval(child: gridWidget),
    );
  }

  Widget _buildParticipantGridItem(
    BuildContext context,
    ConversationMember member,
    double fullSize,
  ) {
    final avatar = member.user?.avatar ?? '';
    final name = (member.user?.firstName ?? 'U');
    final hashId = member.userId;

    if (avatar.isNotEmpty) {
      return SizedBox.expand(
        child: CachedNetworkImage(
          imageUrl: avatar,
          cacheManager: CacheManagers.messageCacheManager,
          fit: BoxFit.cover,
        ),
      );
    }

    final initials = _getInitials(name);
    final fontSize = fullSize * 0.3;

    return Container(
      color: _getBackgroundColor(hashId),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: _getForegroundColor(hashId),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String hashId, String title) {
    final initials = _getInitials(title);
    final bgColor = _getBackgroundColor(hashId);
    final fgColor = _getForegroundColor(hashId);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: fgColor,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
