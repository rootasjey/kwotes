import "package:flutter/material.dart";
import "package:simple_animations/simple_animations.dart";

/// Animate translateX and opacity of a child widget.
class FadeInX extends StatelessWidget {
  const FadeInX({
    super.key,
    this.beginX = 0.0,
    this.child,
    this.delay = const Duration(seconds: 0),
    this.endX = 0.0,
  });

  final double beginX;
  final double endX;
  final Duration delay;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final MovieTween tween = MovieTween()
      ..scene(duration: const Duration(milliseconds: (200)))
          .tween("opacity", Tween(begin: 0.0, end: 1.0))
          .tween("x", Tween(begin: beginX, end: endX));

    return PlayAnimationBuilder<Movie>(
      tween: tween,
      delay: delay,
      duration: tween.duration,
      child: child,
      builder: (BuildContext context, Movie value, Widget? child) {
        return Opacity(
          opacity: value.get("opacity"),
          child: Transform.translate(
            offset: Offset(value.get("x"), 0),
            child: child,
          ),
        );
      },
    );
  }
}
