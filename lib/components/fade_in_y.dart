import "package:flutter/material.dart";
import "package:simple_animations/simple_animations.dart";

/// Animate translateY and opacity of a child widget.
class FadeInY extends StatelessWidget {
  const FadeInY({
    super.key,
    this.beginY = 0.0,
    this.child,
    this.delay = const Duration(seconds: 0),
    this.endY = 0.0,
  });

  final double beginY;
  final double endY;
  final Duration delay;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final MovieTween tween = MovieTween()
      ..scene(duration: const Duration(milliseconds: (200)))
          .tween("opacity", Tween(begin: 0.0, end: 1.0))
          .tween("y", Tween(begin: beginY, end: endY));

    return PlayAnimationBuilder<Movie>(
      tween: tween,
      delay: delay,
      duration: tween.duration,
      child: child,
      builder: (BuildContext context, Movie value, Widget? widget) {
        return Opacity(
          opacity: value.get("opacity"),
          child: Transform.translate(
            offset: Offset(0, value.get("y")),
            child: child,
          ),
        );
      },
    );
  }
}
