import "package:flutter/material.dart";

class DotIndicator extends StatelessWidget {
  /// A dot indicator widget of a specific color.
  const DotIndicator({
    super.key,
    this.color = Colors.transparent,
    this.size = 8.0,
  });

  /// Color of the dot.
  final Color color;

  /// Size of the dot.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: color,
      ),
    );
  }
}
