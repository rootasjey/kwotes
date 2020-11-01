import 'package:flutter/material.dart';

class AnimatedAppIcon extends StatelessWidget {
  final double size;

  AnimatedAppIcon({this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app-icon-animation.gif',
      height: size,
      width: size,
    );
  }
}
