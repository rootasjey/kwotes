import 'package:flutter/material.dart';

/// An alternative to IconButton.
class CircleButton extends StatelessWidget {
  /// Tap callback.
  final VoidCallback onTap;

  /// Typically an Icon.
  final Widget icon;

  /// Size in radius of the widget.
  final double radius;

  /// Widget content backrgound color.
  final Color backgroundColor;

  final double elevation;

  CircleButton({
    this.onTap,
    @required this.icon,
    this.radius = 20.0,
    this.elevation = 0.0,
    this.backgroundColor = Colors.black12,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      elevation: elevation,
      child: Ink(
        child: InkWell(
          onTap: onTap,
          child: CircleAvatar(
            child: icon,
            backgroundColor: backgroundColor,
            radius: radius,
          ),
        ),
      ),
    );
  }
}
