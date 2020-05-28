import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedAppIcon extends StatelessWidget {
  final double size;

  AnimatedAppIcon({this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Spinnies(
          duration: Duration(seconds: 6),
          blendMode: BlendMode.screen,
        ),
      ),
    );
  }
}


/// A Widget that can be configured to show funky spinning rectangles!
///
/// ### Usage
///
/// ```
/// Spinnies(
///   duration: Duration(milliseconds: 2500),
///   rects: [
///     SpinRect(color: Color(0xFFDB4437), begin: 0.0, end: 1.0),
///     SpinRect(color: Color(0xFFF4B400), begin: 0.25, end: 1.25),
///     SpinRect(color: Color(0xFF4285F4), begin: 0.5, end: 1.5),
///     SpinRect(color: Color(0xFF0F9D58), begin: 0.75, end: 1.75),
///   ],
/// );
/// ```
class Spinnies extends StatefulWidget {
  final Duration duration;
  final List<SpinRect> rects;
  final BlendMode blendMode;

  Spinnies({
    Key key,
    @required this.duration,
    this.blendMode = BlendMode.screen,
    List<SpinRect> rects,
  })  : this.rects = rects ??
            [
              SpinRect(color: Color(0xFF4B6ECC), begin: 0.0, end: 1.0),
              SpinRect(color: Color(0xFF5279E1), begin: 0.25, end: 1.25),
              SpinRect(color: Color(0xFF839DE3), begin: 0.5, end: 1.5),
            ],
        super(key: key);

  @override
  _SpinniesState createState() => _SpinniesState();
}

class _SpinniesState extends State<Spinnies>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward()
      ..repeat();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpinniesPainter(
        blendMode: widget.blendMode,
        rects: widget.rects,
        animation: _controller,
      ),
    );
  }
}

class SpinniesPainter extends CustomPainter {
  final List<SpinRect> rects;

  // We accept the animation for two reasons: first, it drives when the custom
  // painter should repaint. Second, it allows us to get the current value of
  // the animation so we can use that to calculate the current rotation of each
  // SpinRect.
  final Animation<double> animation;
  final BlendMode blendMode;

  Size _cachedSize;
  RRect _cachedFunkyRect;

  SpinniesPainter({
    @required this.rects,
    @required this.animation,
    @required this.blendMode,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Create a separate layer for the canvas, so the rects will not be
    // composited onto the background color.
    canvas.saveLayer(null, Paint());

    // Defines the Rect we'll be drawing and it's funky border radii
    final funkyRect = _buildFunkyRect(size);

    // The drawing portion of the class. It is responsible for drawing all of
    // the different rectangles.
    for (final rect in rects) {
      canvas.save();

      // Rotate the correct amount around an origin point
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(rect.tween.transform(animation.value) * pi * 2);
      canvas.translate(-size.width / 2, -size.height / 2);

      // Then draw the rectangle
      canvas.drawRRect(
          funkyRect,
          Paint()
            ..blendMode = blendMode
            ..strokeWidth = rect.strokeWidth
            ..style = PaintingStyle.stroke
            ..color = rect.color);

      canvas.restore();
    }

    // Undo the saveLayer
    canvas.restore();
  }

  @override
  bool shouldRepaint(SpinniesPainter oldDelegate) {
    return true;
  }

  RRect _buildFunkyRect(Size size) {
    if (size != _cachedSize) {
      _cachedFunkyRect = RRect.fromLTRBAndCorners(
        0.0,
        0.0,
        size.width,
        size.height,
        topLeft: Radius.elliptical(
          size.width * 1.15,
          size.height * 1.25,
        ),
        topRight: Radius.elliptical(
          size.width * 1.40,
          size.height * 1.40,
        ),
        bottomRight: Radius.elliptical(
          size.width * 1.45,
          size.height * 1.10,
        ),
        bottomLeft: Radius.elliptical(
          size.width * 1.10,
          size.height * 1.25,
        ),
      );

      _cachedSize = size;
    }

    return _cachedFunkyRect;
  }
}

class SpinRect {
  final Color color;
  final double strokeWidth;
  final Tween<double> tween;

  SpinRect({
    @required this.color,
    @required double begin,
    @required double end,
    this.strokeWidth = 16.0,
  }) : tween = Tween<double>(begin: begin, end: end);
}
