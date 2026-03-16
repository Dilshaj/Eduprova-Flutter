import 'package:flutter/material.dart';

class LinkedTitle extends StatelessWidget {
  final String title;
  final String? url;
  final TextStyle style;

  const LinkedTitle({
    super.key,
    required this.title,
    this.url,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Text(title, style: style);
    }

    return Text(title, style: style);
  }
}
