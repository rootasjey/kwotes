import 'package:fig_style/types/enums.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

/// Animate translateY and opacity of a child widget.
class FadeInY extends StatelessWidget {
  final Duration delay;
  final Widget child;

  final double beginY;
  final double endY;

  FadeInY({
    this.beginY = 0.0,
    this.child,
    this.delay = const Duration(seconds: 0),
    this.endY = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AniProps>()
      ..add(AniProps.opacity, 0.0.tweenTo(1.0), 500.milliseconds)
      ..add(AniProps.translateY, Tween(begin: beginY, end: endY),
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
            offset: Offset(0, value.get(AniProps.translateY)),
            child: child,
          ),
        );
      },
    );
  }
}
