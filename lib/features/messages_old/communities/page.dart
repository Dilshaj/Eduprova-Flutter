import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/community_model.dart';
import '../repository/community_repository.dart';
import 'widgets/communities_groups.dart';

class CommunitiesPage extends StatefulWidget {
  final VoidCallback? onBack;
  final String? searchQuery;

  const CommunitiesPage({super.key, this.onBack, this.searchQuery});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  final CommunityRepository _communityRepository = CommunityRepository();

  List<CommunityModel> _communities = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final communities = await _communityRepository.fetchCommunities();
      if (!mounted) return;
      setState(() {
        _communities = communities;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load communities';
        _isLoading = false;
      });
    }
  }

  Future<CommunityModel?> _createCommunity(
    String name,
    String description,
  ) async {
    try {
      final community = await _communityRepository.createCommunity(
        name: name,
        description: description,
      );
      if (!mounted) return null;
      setState(() {
        _communities = [community, ..._communities];
      });
      return community;
    } catch (_) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create community')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, style: GoogleFonts.inter(fontSize: 16)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadCommunities,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CommunitiesGroupsScreen(
      onBack: widget.onBack,
      searchQuery: widget.searchQuery,
      communities: _communities,
      onCreateCommunity: _createCommunity,
      onRefresh: _loadCommunities,
    );
  }
}
