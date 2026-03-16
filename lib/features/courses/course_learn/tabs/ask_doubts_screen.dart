import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:eduprova/features/communication/providers/doubts_provider.dart';
import 'package:eduprova/features/communication/providers/ai_provider.dart';
import 'package:intl/intl.dart';

class AskDoubtsScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String? lectureId;

  const AskDoubtsScreen({super.key, required this.courseId, this.lectureId});

  @override
  ConsumerState<AskDoubtsScreen> createState() => _AskDoubtsScreenState();
}

class _AskDoubtsScreenState extends ConsumerState<AskDoubtsScreen> {
  String _activeToggle = 'COMMUNITY'; // Changed default to COMMUNITY for now
  final ScrollController _aiScrollController = ScrollController();

  // AI Chat State
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _aiInputController = TextEditingController();

  // Community Doubts State
  final TextEditingController _doubtTitleController = TextEditingController();
  final TextEditingController _doubtExplanationController =
      TextEditingController();
  final TextEditingController _doubtTagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _aiScrollController.dispose();
    _aiInputController.dispose();
    _doubtTitleController.dispose();
    _doubtExplanationController.dispose();
    _doubtTagsController.dispose();
    super.dispose();
  }

  Future<void> _handleSendAI() async {
    final query = _aiInputController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': query,
        'sender': 'user',
      });
      _aiInputController.clear();
      // Add a loading placeholder
      _messages.add({'id': 'loading', 'text': 'Thinking...', 'sender': 'ai'});
    });

    _scrollToBottom();

    try {
      final response = await ref
          .read(aiProvider)
          .askAi(
            query: query,
            courseId: widget.courseId,
            lectureId: widget.lectureId,
          );

      if (mounted) {
        setState(() {
          // Remove loading placeholder
          _messages.removeWhere((msg) => msg['id'] == 'loading');

          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': response,
            'sender': 'ai',
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Remove loading placeholder
          _messages.removeWhere((msg) => msg['id'] == 'loading');

          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': 'Error: Failed to connect to AI tutor. Please try again.',
            'sender': 'ai',
          });
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_aiScrollController.hasClients) {
        _aiScrollController.animateTo(
          _aiScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (BuildContext dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildDialogContent(dialogContext),
          ),
        );
      },
    ).then((_) {
      // Clear fields when dialog closes
      _doubtTitleController.clear();
      _doubtExplanationController.clear();
      _doubtTagsController.clear();
    });
  }

  Widget _buildDialogContent(BuildContext dialogContext) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post to Community',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Share your doubt with other students and instructors.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).extension<AppDesignExtension>()!.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => Navigator.pop(dialogContext),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).extension<AppDesignExtension>()!.skeletonBase,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).extension<AppDesignExtension>()!.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Doubt Title *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _doubtTitleController,
            decoration: _buildInputDecoration('Briefly describe your doubt...'),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Text(
            'Detailed Explanation *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _doubtExplanationController,
            maxLines: 4,
            decoration: _buildInputDecoration(
              'Explain your doubt in detail...',
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Text(
            'Tags (Optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _doubtTagsController,
            decoration: _buildInputDecoration(
              'e.g. React, Hooks (comma separated)',
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pop(dialogContext),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).extension<AppDesignExtension>()!.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).extension<AppDesignExtension>()!.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _handlePostDoubt();
                    Navigator.pop(dialogContext);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Post Doubt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Theme.of(context).extension<AppDesignExtension>()!.secondaryText,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).extension<AppDesignExtension>()!.borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).extension<AppDesignExtension>()!.borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Future<void> _handlePostDoubt() async {
    if (_doubtTitleController.text.trim().isEmpty ||
        _doubtExplanationController.text.trim().isEmpty) {
      return;
    }

    final success = await ref
        .read(allDoubtsProvider.notifier)
        .createDoubt(
          courseId: widget.courseId,
          lectureId:
              widget.lectureId ??
              '', // Requires a lecture ID based on schema, handle gracefully
          title: _doubtTitleController.text.trim(),
          content: _doubtExplanationController.text.trim(),
        );

    if (mounted) {
      if (success) {
        // Clear inputs after success
        _doubtTitleController.clear();
        _doubtExplanationController.clear();
        _doubtTagsController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doubt posted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to post doubt')));
      }
    }
  }

  Widget _buildAskBtn({
    required IconData icon,
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? themeExt.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: themeExt.shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? colorScheme.primary : themeExt.secondaryText,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? colorScheme.primary
                      : themeExt.secondaryText,
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
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header Custom Toggle Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24 + 48, 24, 0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: themeExt.skeletonBase,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildAskBtn(
                    icon: Icons.memory,
                    text: 'Ask AI',
                    isActive: _activeToggle == 'AI',
                    onTap: () => setState(() => _activeToggle = 'AI'),
                  ),
                  _buildAskBtn(
                    icon: Icons.people_outline,
                    text: 'Ask Community',
                    isActive: _activeToggle == 'COMMUNITY',
                    onTap: () => setState(() => _activeToggle = 'COMMUNITY'),
                  ),
                ],
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: _activeToggle == 'AI' ? _buildAskAI() : _buildAskCommunity(),
          ),
        ],
      ),
    );
  }

  Widget _buildAskAI() {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _aiScrollController,
            padding: const EdgeInsets.all(20),
            itemCount: _messages.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: themeExt.cardColor != Colors.transparent
                            ? colorScheme.onSurface
                            : themeExt.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.sentiment_satisfied_alt,
                          size: 40,
                          color: themeExt.cardColor != Colors.transparent
                              ? colorScheme.surface
                              : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Instant AI Help',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Get immediate answers to any technical doubts from your AI tutor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: themeExt.secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              }

              final msgIndex = index - 1;
              final msg = _messages[msgIndex];
              final isUser = msg['sender'] == 'user';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isUser)
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 8, bottom: 4),
                        decoration: BoxDecoration(
                          color: themeExt.cardColor != Colors.transparent
                              ? colorScheme.onSurface
                              : const Color(0xFF111827),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sentiment_satisfied_alt,
                          size: 16,
                          color: themeExt.cardColor != Colors.transparent
                              ? colorScheme.surface
                              : Colors.white,
                        ),
                      ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? colorScheme.primary
                              : themeExt.skeletonBase,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isUser
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottomRight: isUser
                                ? Radius.zero
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            fontSize: 14,
                            color: isUser
                                ? Colors.white
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            border: Border(
              top: BorderSide(color: themeExt.skeletonBase, width: 1),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: themeExt.scaffoldBackgroundColor,
              border: Border.all(color: themeExt.borderColor),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aiInputController,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Ask AI tutor something...',
                      hintStyle: TextStyle(
                        color: themeExt.secondaryText,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _handleSendAI,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAskCommunity() {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final doubtsState = ref.watch(doubtsProvider(widget.courseId));
    final doubts = doubtsState.doubts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: themeExt.skeletonBase,
                border: Border.all(color: themeExt.borderColor),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confused? Ask the community',
                    style: TextStyle(
                      color: themeExt.secondaryText,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  InkWell(
                    onTap: _openModal,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: themeExt.cardColor != Colors.transparent
                            ? themeExt.cardColor
                            : colorScheme.surface,
                        border: Border.all(color: themeExt.borderColor),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'ASK COMMUNITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'COMMUNITY DOUBTS (${doubts.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(
                    context,
                  ).extension<AppDesignExtension>()!.secondaryText,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          if (doubtsState.isLoading && doubts.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (doubtsState.error != null && doubts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text(doubtsState.error!)),
              ),
            )
          else if (doubts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'No doubts yet. Be the first to ask!',
                    style: TextStyle(color: themeExt.secondaryText),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final doubt = doubts[index];
                final isOpen = !doubt.isResolved;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeExt.cardColor,
                    border: Border.all(color: themeExt.borderColor),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  doubt.user.name.isNotEmpty
                                      ? doubt.user.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doubt.user.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.yMMMd().format(doubt.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: themeExt.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? const Color(
                                      0xFF16A34A,
                                    ).withValues(alpha: 0.1)
                                  : const Color(
                                      0xFFF97316,
                                    ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isOpen ? 'OPEN' : 'RESOLVED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isOpen
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFF97316),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doubt.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doubt.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: themeExt.secondaryText,
                          height: 1.5,
                        ),
                      ),
                      if (doubt.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: doubt.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: themeExt.skeletonBase,
                                border: Border.all(color: themeExt.borderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Divider(
                        color: themeExt.borderColor.withValues(alpha: 0.5),
                        height: 1,
                        thickness: 1,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 14,
                                color: themeExt.secondaryText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${doubt.replies.length} answers',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                                color: themeExt.secondaryText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${doubt.views} views',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }, childCount: doubts.length),
            ),
        ],
      ),
    );
  }
}
