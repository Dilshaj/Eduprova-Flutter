import 'package:flutter/material.dart';

class AvatarImg extends StatelessWidget {
  final String url;
  const AvatarImg(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(backgroundImage: NetworkImage(url));
  }
}
