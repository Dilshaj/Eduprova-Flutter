import 'package:flutter/material.dart';

import 'messages-home/page.dart';
import 'communities/page.dart';
import 'calendar/page.dart';
import 'activity/page.dart';

class MessagesShell extends StatefulWidget {
  const MessagesShell({super.key});

  @override
  State<MessagesShell> createState() => _MessagesShellState();
}

class _MessagesShellState extends State<MessagesShell> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        MessagesHomePage(onTabChange: (i) => setState(() => _currentIndex = i)),
        CommunitiesPage(onBack: () => setState(() => _currentIndex = 0)),
        CalendarPage(onBack: () => setState(() => _currentIndex = 0)),
        ActivityPage(onBack: () => setState(() => _currentIndex = 0)),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }
}
