import 'package:flutter/material.dart';

import 'messages-home/page.dart';

class MessagesShell extends StatefulWidget {
  const MessagesShell({super.key});

  @override
  State<MessagesShell> createState() => _MessagesShellState();
}

class _MessagesShellState extends State<MessagesShell> {
  @override
  Widget build(BuildContext context) {
    return const MessagesHomePage();
  }
}
