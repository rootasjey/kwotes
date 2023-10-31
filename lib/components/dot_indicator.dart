import "package:flutter/material.dart";

class DotIndicator extends StatelessWidget {
  /// A dot indicator widget of a specific color.
  const DotIndicator({
    super.key,
    this.color = Colors.transparent,
  });

  /// Color of the dot.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8.0,
      height: 8.0,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: color,
      ),
    );
  }
}
