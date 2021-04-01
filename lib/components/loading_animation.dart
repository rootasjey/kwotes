import 'package:flutter/material.dart';
import 'package:fig_style/components/animated_app_icon.dart';

class LoadingAnimation extends StatelessWidget {
  final TextStyle style;
  final String textTitle;
  final Widget title;
  final double size;

  LoadingAnimation({
    this.size = 100.0,
    this.style = const TextStyle(
      fontSize: 20.0,
    ),
    this.textTitle = 'Loading...',
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedAppIcon(size: size),
        title != null
            ? title
            : Text(textTitle, textAlign: TextAlign.center, style: style),
      ],
    );
  }
}
