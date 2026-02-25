import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class AskDoubtsScreen extends StatefulWidget {
  const AskDoubtsScreen({super.key});

  @override
  State<AskDoubtsScreen> createState() => _AskDoubtsScreenState();
}

class _AskDoubtsScreenState extends State<AskDoubtsScreen> {
  String _activeToggle = 'AI'; // 'AI' or 'COMMUNITY'
  final ScrollController _aiScrollController = ScrollController();

  // AI Chat State
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _aiInputController = TextEditingController();

  // Community Doubts State
  bool _modalVisible = false;
  final TextEditingController _doubtTitleController = TextEditingController();
  final TextEditingController _doubtExplanationController =
      TextEditingController();
  final TextEditingController _doubtTagsController = TextEditingController();

  final List<Map<String, dynamic>> _doubts = [
    {
      'id': '1',
      'user': {'name': 'Rahul S.', 'avatar': 'RS'},
      'time': '2H AGO',
      'title': 'How do I center a div using Grid?',
      'description':
          'I have tried using justify-content and align-items but it is not working as expected.',
      'tags': ['CSS', 'Grid'],
      'status': 'OPEN',
      'comments': 3,
      'views': 45,
    },
    {
      'id': '2',
      'user': {'name': 'Simran K.', 'avatar': 'SK'},
      'time': '5H AGO',
      'title': 'Is this compatible with older browsers?',
      'description':
          'Trying to use the new clamp() function but worried about support.',
      'tags': ['CSS', 'Compatibility'],
      'status': 'PENDING',
      'comments': 1,
      'views': 12,
    },
  ];

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

  void _handleSendAI() {
    if (_aiInputController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': _aiInputController.text,
        'sender': 'user',
      });
      _aiInputController.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          'text':
              "I'm analyzing your doubt... standard AI response placeholder.",
          'sender': 'ai',
        });
      });
      _scrollToBottom();
    });
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
    setState(() {
      _modalVisible = true;
    });
  }

  void _closeModal() {
    setState(() {
      _modalVisible = false;
      _doubtTitleController.clear();
      _doubtExplanationController.clear();
      _doubtTagsController.clear();
    });
  }

  void _handlePostDoubt() {
    if (_doubtTitleController.text.trim().isEmpty ||
        _doubtExplanationController.text.trim().isEmpty) {
      return;
    }

    final tags = _doubtTagsController.text
        .split(',')
        .where((t) => t.trim().isNotEmpty)
        .map((t) => t.trim())
        .toList();

    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user': {'name': 'You', 'avatar': 'ME'},
      'time': 'Just now',
      'title': _doubtTitleController.text,
      'description': _doubtExplanationController.text,
      'tags': tags,
      'status': 'OPEN',
      'comments': 0,
      'views': 0,
    };

    setState(() {
      _doubts.insert(0, newPost);
    });
    _closeModal();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorSchema = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorSchema.surface,
          body: Column(
            children: [
              // Header Custom Toggle Buttons (as in Image 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Ask AI Button
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _activeToggle = 'AI'),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _activeToggle == 'AI'
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _activeToggle == 'AI'
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
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
                                  Icons
                                      .memory, // Changed to match prompt's ask AI icon logic if needed, but keeping Icons.memory
                                  size: 18,
                                  color: _activeToggle == 'AI'
                                      ? const Color(0xFF0066FF)
                                      : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ask AI',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _activeToggle == 'AI'
                                        ? const Color(0xFF0066FF)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Ask Community Button
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              setState(() => _activeToggle = 'COMMUNITY'),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _activeToggle == 'COMMUNITY'
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _activeToggle == 'COMMUNITY'
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
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
                                  Icons.people_outline,
                                  size: 18,
                                  color: _activeToggle == 'COMMUNITY'
                                      ? const Color(0xFF0066FF)
                                      : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ask Community',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _activeToggle == 'COMMUNITY'
                                        ? const Color(0xFF0066FF)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: _activeToggle == 'AI'
                    ? _buildAskAI()
                    : _buildAskCommunity(),
              ),
            ],
          ),
        ),

        // Modal Custom Implementation
        if (_modalVisible)
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 250),
              builder: (context, value, child) {
                return Stack(
                  children: [
                    // Backdrop
                    Opacity(
                      opacity: value,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    ),
                    // Dialog
                    Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.9 + (0.1 * value),
                        child: Center(
                          child: Material(
                            color: Colors.transparent,
                            child: SingleChildScrollView(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                constraints: const BoxConstraints(
                                  maxWidth: 480,
                                ),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Post to Community',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Share your doubt with other students and instructors.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        InkWell(
                                          onTap: _closeModal,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF3F4F6),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 18,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Doubt Title *',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _doubtTitleController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Briefly describe your doubt...',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF9FAFB),
                                        contentPadding: const EdgeInsets.all(
                                          14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF0066FF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Detailed Explanation *',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _doubtExplanationController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Explain your doubt in detail...',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF9FAFB),
                                        contentPadding: const EdgeInsets.all(
                                          14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF0066FF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Tags (Optional)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _doubtTagsController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'e.g. React, Hooks (comma separated)',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF9FAFB),
                                        contentPadding: const EdgeInsets.all(
                                          14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF0066FF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: _closeModal,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE5E7EB,
                                                  ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF374151),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: InkWell(
                                            onTap: _handlePostDoubt,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2563EB),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF3B82F6,
                                                    ).withValues(alpha: 0.3),
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
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAskAI() {
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
                        color: const Color(0xFF111827),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sentiment_satisfied_alt,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Instant AI Help',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Get immediate answers to any technical doubts from your AI tutor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
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
                        decoration: const BoxDecoration(
                          color: Color(0xFF111827),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sentiment_satisfied_alt,
                          size: 16,
                          color: Colors.white,
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
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFF3F4F6),
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
                                : const Color(0xFF1F2937),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
                    decoration: const InputDecoration(
                      hintText: 'Ask AI tutor something...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  const Text(
                    'Confused? Ask the community',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
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
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Text(
                        'ASK COMMUNITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
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
                'COMMUNITY DOUBTS (${_doubts.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final doubt = _doubts[index];
              final isOpen = doubt['status'] == 'OPEN';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF3F4F6)),
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
                              decoration: const BoxDecoration(
                                color: Color(0xFFDBEAFE),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                doubt['user']['avatar'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doubt['user']['name'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  doubt['time'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF),
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
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            doubt['status'],
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
                      doubt['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      doubt['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                    if ((doubt['tags'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (doubt['tags'] as List<String>).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(
                      color: Color(0xFFF9FAFB),
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${doubt['comments']} answers',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye_outlined,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${doubt['views']} views',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }, childCount: _doubts.length),
          ),
        ],
      ),
    );
  }
}
