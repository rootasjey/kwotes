import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class DarkElevatedButton extends StatelessWidget {
  const DarkElevatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
  }) : super(key: key);

  final Color? backgroundColor;

  /// Callback fired when this widget is pressed.
  final void Function()? onPressed;

  /// Child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor ?? Colors.black,
        textStyle: Utils.calligraphy.body(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: child,
      ),
    );
  }

  static Widget large({
    void Function()? onPressed,
    required Widget child,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Padding(
      padding: margin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          minimumSize: const Size(340.0, 0.0),
          textStyle: Utils.calligraphy.body(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: child,
        ),
      ),
    );
  }

  static Widget icon({
    required IconData iconData,
    required String labelValue,
    Function()? onPressed,
    Color? background,
    Color? foreground,
    double? elevation,
    EdgeInsets margin = EdgeInsets.zero,
    Size? minimumSize = const Size(200.0, 60.0),
  }) {
    return Padding(
      padding: margin,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            iconData,
            color: foreground,
          ),
        ),
        label: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            labelValue,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: background ?? Constants.colors.clairPink,
          minimumSize: minimumSize,
        ),
      ),
    );
  }

  static Widget iconOnly({
    void Function()? onPressed,
    required Widget child,
    Color color = Colors.black,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        textStyle: Utils.calligraphy.body(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2.0,
          vertical: 10.0,
        ),
        child: child,
      ),
    );
  }
}
