import 'package:flutter/material.dart';
import 'widgets/communities_groups.dart';
import 'utils/community_utils.dart';

class CommunitiesPage extends StatefulWidget {
  final VoidCallback? onBack;
  const CommunitiesPage({super.key, this.onBack});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  late List<Map<String, dynamic>> _communities;

  @override
  void initState() {
    super.initState();
    _communities = List.from(initialCommunities);
  }

  void _addNewCommunity(Map<String, dynamic> data) {
    setState(() {
      _communities.insert(0, data);
    });
  }

  void _updateGroups(String communityId, List<Map<String, dynamic>> channels) {
    setState(() {
      final index = _communities.indexWhere((c) => c['id'] == communityId);
      if (index != -1) {
        _communities[index]['channels'] = channels;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommunitiesGroupsScreen(
      onBack: widget.onBack,
      communities: _communities,
      onAddNewCommunity: _addNewCommunity,
      onUpdateGroups: _updateGroups,
    );
  }
}
