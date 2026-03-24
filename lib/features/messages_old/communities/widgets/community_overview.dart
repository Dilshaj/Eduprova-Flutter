import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/theme.dart';
import '../../models/community_model.dart';
import '../../models/conversation_model.dart';
import '../../repository/community_repository.dart';

class CommunityOverviewScreen extends StatefulWidget {
  final String communityId;
  final CommunityModel? initialCommunity;

  const CommunityOverviewScreen({
    super.key,
    required this.communityId,
    this.initialCommunity,
  });

  @override
  State<CommunityOverviewScreen> createState() =>
      _CommunityOverviewScreenState();
}

class _CommunityOverviewScreenState extends State<CommunityOverviewScreen> {
  final CommunityRepository _communityRepository = CommunityRepository();
  final ImagePicker _imagePicker = ImagePicker();

  CommunityModel? _community;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _community = widget.initialCommunity;
    _loadCommunity();
  }

  Future<void> _loadCommunity() async {
    setState(() => _isLoading = true);
    try {
      final community = await _communityRepository.fetchCommunity(
        widget.communityId,
      );
      if (!mounted) return;
      setState(() {
        _community = community;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load community')));
    }
  }

  Future<void> _showCreateGroupDialog() async {
    final nameController = TextEditingController();
    XFile? selectedImage;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final themeExt = context.design;

        return StatefulBuilder(
          builder: (context, setModalState) => AlertDialog(
            backgroundColor: themeExt.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Create New Group',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Group name',
                      hintText: 'e.g. Backend Team',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Group Icon',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: themeExt.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final image = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image == null) return;
                      setModalState(() => selectedImage = image);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: themeExt.borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: themeExt.avatarBackgroundColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              selectedImage == null
                                  ? 'Choose an image for the group icon'
                                  : selectedImage!.name,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: themeExt.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: themeExt.secondaryText),
                ),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  Navigator.pop(ctx, true);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || nameController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final group = await _communityRepository.createCommunityGroup(
        communityId: widget.communityId,
        name: nameController.text.trim(),
      );

      if (selectedImage != null) {
        final bytes = await selectedImage!.readAsBytes();
        final avatarDataUri =
            'data:${_mimeTypeForName(selectedImage!.name)};base64,${base64Encode(bytes)}';
        await _communityRepository.updateConversation(
          group.id,
          avatar: avatarDataUri,
        );
      }

      await _loadCommunity();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to create group')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _mimeTypeForName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Widget _buildGroupRow(ConversationModel group) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = context.design;

    final name = group.name ?? 'Unnamed group';
    final isAnnouncements =
        group.type == ConversationType.announcement ||
        name.toLowerCase().contains('announcement');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/chat/${group.id}'),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: themeExt.borderColor),
            boxShadow: [
              BoxShadow(
                color: themeExt.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: themeExt.avatarBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: group.avatar != null && group.avatar!.isNotEmpty
                    ? Image.network(
                        group.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          isAnnouncements
                              ? Icons.campaign_outlined
                              : Icons.groups_outlined,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                      )
                    : Icon(
                        isAnnouncements
                            ? Icons.campaign_outlined
                            : Icons.groups_outlined,
                        color: colorScheme.primary,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isAnnouncements
                                ? themeExt.warningColor.withValues(alpha: 0.1)
                                : colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isAnnouncements ? 'Broadcast' : 'Discussion',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAnnouncements
                                  ? themeExt.warningColor
                                  : themeExt.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAnnouncements
                          ? 'Official updates and news from admins'
                          : 'Community discussion group',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: themeExt.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = context.design;

    final community = _community;

    if (_isLoading && community == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (community == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Community not found')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: Icon(Icons.close, color: colorScheme.onSurface),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _showCreateGroupDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
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
                    _isSubmitting ? 'Creating...' : 'Create Group',
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
            onPressed: _loadCommunity,
            icon: Icon(Icons.refresh, color: themeExt.secondaryText),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCommunity,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          community.avatar != null &&
                              community.avatar!.isNotEmpty
                          ? Image.network(
                              community.avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.groups_outlined,
                                color: colorScheme.onPrimary,
                                size: 32,
                              ),
                            )
                          : Icon(
                              Icons.groups_outlined,
                              color: colorScheme.onPrimary,
                              size: 32,
                            ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  community.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'COMMUNITY',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${community.groups.length} groups',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${community.description ?? 'No description'}"',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: themeExt.secondaryText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${community.memberCount} members',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: themeExt.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tag, size: 20, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Community Channels',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Pull to refresh',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...community.groups.map(_buildGroupRow),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
