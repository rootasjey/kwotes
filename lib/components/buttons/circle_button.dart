import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class CircleButton extends StatelessWidget {
  /// An alternative to IconButton.
  const CircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.radius = 20.0,
    this.elevation = 0.0,
    this.backgroundColor = Colors.black12,
    this.tooltip,
    this.margin = EdgeInsets.zero,
    this.shape = const CircleBorder(side: BorderSide.none),
  });

  /// Callback fired when the button is tapped.
  final void Function()? onTap;

  /// Tooltip string.
  final String? tooltip;

  /// Typically an Icon.
  final Widget icon;

  /// Size in radius of the widget.
  final double radius;

  /// Widget content backrgound color.
  final Color backgroundColor;

  /// This button's elevation. Shadow will be painted behind.
  final double elevation;

  /// Spacing outside of this button.
  final EdgeInsets margin;

  /// Defines the material's shape as well its shadow.
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    Widget child = Ink(
      child: InkWell(
        onTap: onTap,
        canRequestFocus: false,
        child: CircleAvatar(
          backgroundColor: backgroundColor,
          foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
          radius: radius,
          child: icon,
        ),
      ),
    );

    if (tooltip != null) {
      child = Utils.graphic.tooltip(
        tooltipString: tooltip ?? "",
        child: child,
      );
    }

    return Padding(
      padding: margin,
      child: Material(
        shape: shape,
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        elevation: elevation,
        child: child,
      ),
    );
  }

  static Widget outlined({
    required final Function()? onTap,
    required final Widget child,
    Color borderColor = const Color(0xFF000000),
    final EdgeInsets margin = EdgeInsets.zero,
    final String tooltip = "",
  }) {
    return Utils.graphic.tooltip(
      tooltipString: tooltip,
      child: Padding(
        padding: margin,
        child: Container(
          height: 28.0,
          width: 28.0,
          decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: borderColor),
            borderRadius: BorderRadius.circular(24.0),
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            canRequestFocus: false,
            borderRadius: BorderRadius.circular(24.0),
            onTap: onTap,
            child: child,
          ),
        ),
      ),
    );
  }

  static Widget withNoEvent({
    required Icon icon,
    double radius = 20.0,
    double elevation = 0.0,
    Color backgroundColor = Colors.black12,
    String tooltip = "",
    bool showBorder = false,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Padding(
      padding: margin,
      child: Material(
        shape: CircleBorder(
          side: showBorder
              ? const BorderSide(color: Colors.white38, width: 2.0)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        elevation: elevation,
        child: CircleAvatar(
          backgroundColor: backgroundColor,
          radius: radius,
          child: icon,
        ),
      ),
    );
  }
}
