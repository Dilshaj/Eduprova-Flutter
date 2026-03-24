import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  bool _isFocused = false;
  bool _showDropdown = false;
  DateTime? _afterDate;
  DateTime? _beforeDate;
  // Store widget context for use inside overlay callbacks
  late BuildContext _widgetContext;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (!_isFocused) _showDropdown = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _widgetContext = context; // keep a reference for overlay callbacks
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F7FF);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (!_isFocused) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(LucideIcons.chevronLeft, size: 28),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildSearchInput(isDark, cardColor),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft, size: 28),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(child: _buildSearchInput(isDark, cardColor)),
                      ],
                    ),
                  ),
                Expanded(
                  child: _isFocused
                      ? _buildSuggestions(isDark, cardColor)
                      : _buildInitialState(isDark, cardColor),
                ),
              ],
            ),
            if (_showDropdown)
              GestureDetector(
                onTap: () => setState(() => _showDropdown = false),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            if (_showDropdown) _buildDropdownOverlay(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput(bool isDark, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]
            : const Color(0xFFE5E7EB).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onTap: () {
          if (_showDropdown) setState(() => _showDropdown = false);
        },
        decoration: InputDecoration(
          hintText: (_afterDate == null && _beforeDate == null) ? 'Search' : '',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.search,
                  size: 20,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                if (_afterDate != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildInlineChip(
                      'After: ${_afterDate!.day}/${_afterDate!.month}',
                      () => setState(() => _afterDate = null),
                      () => _showDatePickerBottomSheet(
                        context,
                        'After date',
                        isDark,
                      ),
                      isDark,
                    ),
                  ),
                if (_beforeDate != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildInlineChip(
                      'Before: ${_beforeDate!.day}/${_beforeDate!.month}',
                      () => setState(() => _beforeDate = null),
                      () => _showDatePickerBottomSheet(
                        context,
                        'Before date',
                        isDark,
                      ),
                      isDark,
                    ),
                  ),
              ],
            ),
          ),
          suffixIcon: CompositedTransformTarget(
                  link: _layerLink,
                  child: IconButton(
                    icon: Icon(
                      LucideIcons.slidersHorizontal,
                      size: 20,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _showDropdown = !_showDropdown;
                      });
                    },
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildInlineChip(
    String label,
    VoidCallback onClear,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.blue.withValues(alpha: 0.3) : Colors.blue[100]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.blue[200] : Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClear,
              child: Icon(
                LucideIcons.x,
                size: 14,
                color: isDark ? Colors.blue[200] : Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownOverlay(bool isDark) {
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: const Offset(-180, 48), // slightly more space
      child: Material(
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                'After date',
                LucideIcons.history,
                'after',
                isDark,
              ),
              _buildMenuItem(
                'Before date',
                LucideIcons.history,
                'before',
                isDark,
              ),
              _buildMenuItem(
                'From profile',
                LucideIcons.user,
                'profile',
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    String value,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        setState(() => _showDropdown = false);
        if (value == 'after' || value == 'before') {
          // Use the stored widget context — the overlay context is detached
          final ctx = _widgetContext;
          final title = value == 'after' ? 'After date' : 'Before date';
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _showDatePickerBottomSheet(ctx, title, isDark);
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17, // slight increase for Threads look
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              icon,
              size: 22,
              color: isDark ? Colors.grey[400] : Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePickerBottomSheet(
    BuildContext context,
    String title,
    bool isDark,
  ) {
    DateTime selectedDate =
        (title == 'After date' ? _afterDate : _beforeDate) ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    onDateTimeChanged: (DateTime newDate) {
                      setModalState(() {
                        selectedDate = newDate;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (title == 'After date') {
                        _afterDate = selectedDate;
                      } else {
                        _beforeDate = selectedDate;
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState(bool isDark, Color cardColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileTile(
            'vaibhavsisinty',
            'Vaibhav Sisinty',
            '75.6K followers',
            true,
            isDark,
          ),
          _buildProfileTile(
            '_.hemanthhhhh._',
            'Sai Hemanth Pediredla ...',
            '97 followers',
            false,
            isDark,
          ),
          _buildProfileTile(
            'catherinetresa',
            'Catherine Tresa Alexan...',
            '314K followers',
            true,
            isDark,
          ),
          _buildProfileTile(
            'krystledsouza',
            'Krystle Dsouza',
            '745K followers',
            true,
            isDark,
          ),
          _buildProfileTile(
            'manish__tripurana',
            'Manish Tripurana',
            '27 followers',
            false,
            isDark,
          ),
          _buildProfileTile(
            '_sai_304',
            'S A I',
            '6.7K followers',
            false,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(bool isDark, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Recent', onAction: () {}, actionLabel: 'Edit'),
          _buildChip('viji.darshan._', isDark, isRecent: true),
          const SizedBox(height: 24),
          _buildSectionHeader('Topics picked for you'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip('Sunrisers Hyderabad', isDark),
              _buildChip('cleaning hack', isDark),
              _buildChip('Cleaning product', isDark),
              _buildChip('personal flat', isDark),
              _buildChip('washing machine', isDark),
              _buildChip('stewardship matter', isDark),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            'Popular communities',
            onAction: () {},
            actionLabel: 'See more',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip('Content Creators', isDark, icon: LucideIcons.atom),
              _buildChip('Mom Threads', isDark, icon: LucideIcons.atom),
              _buildChip('Health', isDark, icon: LucideIcons.atom),
              _buildChip('Design Threads', isDark, icon: LucideIcons.atom),
              _buildChip('Home Decor', isDark, icon: LucideIcons.atom),
              _buildChip('Parenting Th...', isDark, icon: LucideIcons.atom),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular topics'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChip(
    String label,
    bool isDark, {
    bool isRecent = false,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRecent)
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?u=123'),
                ),
              ),
            ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                icon,
                size: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onClear, bool isDark) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      deleteIcon: Icon(
        LucideIcons.x,
        size: 14,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
      onDeleted: onClear,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }

  Widget _buildProfileTile(
    String username,
    String fullName,
    String followers,
    bool isVerified,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF0066FF).withValues(alpha: 0.1),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF0066FF), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                Text(
                  fullName,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  followers,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text(
                'Follow',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
