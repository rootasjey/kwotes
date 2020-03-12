import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

/// Animate translateY and opacity of a child widget.
class FadeInY extends StatelessWidget {
  final double delay;
  final Widget child;

  final double beginY;
  final double endY;

  FadeInY({
    this.beginY = 0.0,
    this.child,
    this.delay = 0.0,
    this.endY = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track('opacity')
        .add(
          Duration(milliseconds: 500),
          Tween(begin: 0.0, end: 1.0),
        ),

      Track('translateY')
        .add(
          Duration(milliseconds: 500),
          Tween(begin: beginY, end: endY),
          curve: Curves.easeOut,
        )
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (100 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation['opacity'],
        child: Transform.translate(
          offset: Offset(0, animation['translateY']),
          child: child,
        ),
      ),
    );
  }
}
