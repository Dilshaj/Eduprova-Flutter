import 'dart:async';

import 'package:eduprova/globals.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../models/search_user_model.dart';
import '../repository/participant_search_repository.dart';

class ParticipantPickerScreen extends StatefulWidget {
  final String title;
  final String submitLabel;
  final bool multiSelect;
  final List<SearchUserModel> initialSelected;

  const ParticipantPickerScreen({
    super.key,
    required this.title,
    required this.submitLabel,
    this.multiSelect = true,
    this.initialSelected = const [],
  });

  @override
  State<ParticipantPickerScreen> createState() =>
      _ParticipantPickerScreenState();
}

class _ParticipantPickerScreenState extends State<ParticipantPickerScreen> {
  final ParticipantSearchRepository _repository = ParticipantSearchRepository();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  String _query = '';
  List<SearchUserModel> _results = const [];
  late List<SearchUserModel> _selected = [...widget.initialSelected];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String value) async {
    final query = value.trim();
    setState(() => _query = query);
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final currentUserId = prefs.getString('user_id') ?? '';
      final users = await _repository.searchUsers(query);
      if (!mounted) return;
      setState(() {
        _results = users.where((user) => user.id != currentUserId).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 320),
      () => _runSearch(value),
    );
  }

  bool _isSelected(SearchUserModel user) {
    return _selected.any((item) => item.id == user.id);
  }

  void _toggleUser(SearchUserModel user) {
    setState(() {
      if (widget.multiSelect) {
        if (_isSelected(user)) {
          _selected = _selected.where((item) => item.id != user.id).toList();
        } else {
          _selected = [..._selected, user];
        }
      } else {
        _selected = [user];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.chevronLeft, color: cs.onSurface),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.inter(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () => context.pop(_selected),
            child: Text(
              widget.submitLabel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: _selected.isEmpty ? cs.onSurface.withValues(alpha: 0.3) : cs.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: .fromLTRB(16, 12, 16, 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: .circular(18),
                  border: Border.all(
                    color: const Color(0xFFC084FC).withValues(alpha: 0.6), // Soft purple border
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  autofocus: true,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _runSearch('');
                            },
                            icon: const Icon(LucideIcons.x, size: 18),
                          )
                        : null,
                    border: .none,
                    contentPadding: .symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            if (_selected.isNotEmpty)
              SizedBox(
                height: 54,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _selected.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final user = _selected[index];
                    return InputChip(
                      label: Text(user.displayName),
                      avatar: _UserAvatar(user: user, radius: 12),
                      onDeleted: () => _toggleUser(user),
                    );
                  },
                ),
              ),
            if (_query.isEmpty) ...[
              Padding(
                padding: .symmetric(horizontal: 20),
                child: Align(
                  alignment: .centerLeft,
                  child: Text(
                    'SUGGESTED',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFBCBCCF),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty && _query.isNotEmpty
                      ? const Center(
                          child: Text(
                            'No people found',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        )
                      : ListView.separated(
                        padding: .fromLTRB(16, 8, 16, 24),
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final user = _results[index];
                          final selected = _isSelected(user);
                          return Row(
                            children: [
                              _UserAvatar(user: user, radius: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Text(
                                      user.displayName,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    Text(
                                      user.role.substring(0, 1).toUpperCase() +
                                          user.role.substring(1).toLowerCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: cs.onSurface.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: () => _toggleUser(user),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selected
                                        ? const Color(0xFF3B82F6)
                                        : const Color(0xFFF1F5F9),
                                    foregroundColor:
                                        selected ? Colors.white : const Color(0xFF1F2937),
                                    elevation: 0,
                                    padding: .symmetric(horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: .circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    selected ? 'Sent' : 'Invite',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
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
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final SearchUserModel user;
  final double radius;

  const _UserAvatar({required this.user, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    final avatar = user.avatar;
    if (avatar != null && avatar.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatar),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: Text(_initials(user.displayName)),
    );
  }

  String _initials(String value) {
    final parts = value
        .split(' ')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
