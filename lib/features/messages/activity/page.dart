import 'package:flutter/material.dart';
import 'widgets/activity_screen.dart';

class ActivityPage extends StatelessWidget {
  final VoidCallback? onBack;
  const ActivityPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return ActivityScreen(onBack: onBack);
  }
}
