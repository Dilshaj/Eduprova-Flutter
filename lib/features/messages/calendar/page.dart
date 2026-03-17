import 'package:flutter/material.dart';
import 'widgets/calendar_home_screen.dart';

class CalendarPage extends StatelessWidget {
  final VoidCallback? onBack;
  const CalendarPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return CalendarHomeScreen(onBack: onBack);
  }
}
