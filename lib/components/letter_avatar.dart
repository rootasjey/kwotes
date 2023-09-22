import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class LetterAvatar extends StatefulWidget {
  const LetterAvatar({
    Key? key,
    required this.name,
    this.elevation = 4.0,
    this.onTap,
    this.colorFilter,
    this.borderSide = const BorderSide(
      color: Colors.deepPurple,
      width: 3.0,
    ),
    this.margin = EdgeInsets.zero,
    this.radius = 36.0,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip = "",
  }) : super(key: key);

  /// Avatar's radius.
  final double radius;

  /// Avatar's border side.
  final BorderSide borderSide;

  /// Background color.
  final Color? backgroundColor;

  /// Foreground color.
  final Color? foregroundColor;

  /// Avatar's initial elevation.
  final double elevation;

  /// Callback fired when avatar is tapped.
  final void Function()? onTap;

  /// Space around the avatar.
  final EdgeInsets margin;

  /// Color filter applied to the image.
  /// Not used if onTap is null.
  final ColorFilter? colorFilter;

  /// Typically an username.
  final String name;

  /// Tooltip for the avatar.
  final String tooltip;

  @override
  State<StatefulWidget> createState() => _LetterAvatarState();
}

class _LetterAvatarState extends State<LetterAvatar>
    with TickerProviderStateMixin {
  late Animation<double> scaleAnimation;
  late AnimationController scaleAnimationController;

  late double elevation;

  @override
  void initState() {
    super.initState();

    scaleAnimationController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    scaleAnimation = CurvedAnimation(
      parent: scaleAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    setState(() {
      elevation = widget.elevation;
    });
  }

  @override
  dispose() {
    scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Padding(
        padding: widget.margin,
        child: Tooltip(
          message: widget.tooltip,
          child: InkWell(
            onTap: widget.onTap,
            onHover: (bool isHover) {
              if (isHover) {
                elevation = (widget.elevation + 1.0) * 2;
                scaleAnimationController.forward();
                setState(() {});
                return;
              }

              elevation = widget.elevation;
              scaleAnimationController.reverse();
              setState(() {});
            },
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: widget.backgroundColor,
              child: Text(
                widget.name.substring(0, 1),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: widget.foregroundColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
