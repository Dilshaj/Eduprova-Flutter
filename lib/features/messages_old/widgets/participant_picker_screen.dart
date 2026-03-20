import 'dart:async';

import 'package:eduprova/globals.dart';
import 'package:flutter/material.dart';

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
  State<ParticipantPickerScreen> createState() => _ParticipantPickerScreenState();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.of(context).pop(_selected),
            child: Text(widget.submitLabel),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search people by name or username',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _runSearch('');
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
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
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _query.isEmpty
                  ? const Center(
                      child: Text(
                        'Type to search participants',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    )
                  : _results.isEmpty
                  ? const Center(
                      child: Text(
                        'No people found',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final user = _results[index];
                        final selected = _isSelected(user);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: selected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          tileColor: selected
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,
                          leading: _UserAvatar(user: user),
                          title: Text(user.displayName),
                          subtitle: Text(
                            user.email.isNotEmpty
                                ? user.email
                                : '@${user.username}',
                          ),
                          trailing: Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: selected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF94A3B8),
                          ),
                          onTap: () {
                            _toggleUser(user);
                            if (!widget.multiSelect) {
                              Navigator.of(context).pop([user]);
                            }
                          },
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
