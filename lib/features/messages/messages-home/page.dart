import 'package:flutter/material.dart';
import 'widgets/messages_home_screen.dart';

class MessagesHomePage extends StatelessWidget {
  final Function(int)? onTabChange;
  const MessagesHomePage({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return MessagesHomeScreen(onTabChange: onTabChange);
  }
}
