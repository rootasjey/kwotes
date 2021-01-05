import 'package:figstyle/types/enums.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

/// Animate translateX and opacity of a child widget.
class FadeInX extends StatelessWidget {
  final Duration delay;
  final Widget child;

  final double beginX;
  final double endX;

  FadeInX({
    this.beginX = 0.0,
    this.child,
    this.delay = const Duration(seconds: 0),
    this.endX = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AniProps>()
      ..add(AniProps.opacity, 0.0.tweenTo(1.0), 500.milliseconds)
      ..add(AniProps.translateX, Tween(begin: beginX, end: endX),
          500.milliseconds);

    return PlayAnimation<MultiTweenValues<AniProps>>(
      tween: tween,
      delay: delay,
      duration: tween.duration,
      child: child,
      builder: (context, child, value) {
        return Opacity(
          opacity: value.get(AniProps.opacity),
          child: Transform.translate(
            offset: Offset(value.get(AniProps.translateX), 0),
            child: child,
          ),
        );
      },
    );
  }
}
