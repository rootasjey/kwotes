import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

/// Animate translateX and opacity of a child widget.
class FadeInX extends StatelessWidget {
  final double delay;
  final Widget child;

  final double beginX;
  final double endX;

  FadeInX({
    this.beginX = 0.0,
    this.child,
    this.delay = 0.0,
    this.endX = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track('opacity')
        .add(
          Duration(milliseconds: 500),
          Tween(begin: 0.0, end: 1.0),
        ),

      Track('translateX')
        .add(
          Duration(milliseconds: 500),
          Tween(begin: beginX, end: endX),
          curve: Curves.easeOut,
        )
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation['opacity'],
        child: Transform.translate(
          offset: Offset(animation['translateX'], 0),
          child: child,
        ),
      ),
    );
  }
}
