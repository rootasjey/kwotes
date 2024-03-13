import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class ColoredTextButton extends StatefulWidget {
  /// A stylized text button.
  const ColoredTextButton({
    super.key,
    required this.textValue,
    this.icon,
    this.iconOnly = false,
    this.iconOnRight = false,
    this.accentColor,
    this.backgroundColor,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.iconPadding = const EdgeInsets.only(right: 12.0),
    this.textFlex = 1,
    this.style,
    this.onPressed,
    this.tooltip = "",
    this.textStyle,
    this.textAlign,
  });

  /// Only show icon for this button if true.
  final bool iconOnly;

  /// Show icon at the end if true.
  final bool iconOnRight;

  /// Style for this button.
  final ButtonStyle? style;

  /// Accent color.
  final Color? accentColor;

  /// Button background color.
  final Color? backgroundColor;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Spacing around the text.
  final EdgeInsets padding;

  /// Spacing around the icon.
  final EdgeInsets iconPadding;

  /// Callback fired when user taps this button.
  final void Function()? onPressed;

  /// Creates a widget that expands a child of a [Row], [Column], or [Flex]
  /// so that the child fills the available space along the flex
  /// widget's main axis.
  final int textFlex;

  /// Text value for this button.
  final String textValue;

  /// Tooltip for this button.
  final String tooltip;

  /// Text alignment for this button.
  final TextAlign? textAlign;

  /// Text style for this button.
  final TextStyle? textStyle;

  /// Icon child widget.
  final Widget? icon;

  @override
  State<ColoredTextButton> createState() => _ColoredTextButtonState();
}

class _ColoredTextButtonState extends State<ColoredTextButton> {
  /// True if the button is hovered by a cursor.
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: Padding(
        padding: widget.margin,
        child: TextButton(
          onPressed: widget.onPressed,
          onHover: (bool isHover) => setState(() => _isHover = isHover),
          style: TextButton.styleFrom(
            backgroundColor: _isHover ? null : widget.backgroundColor,
          ).merge(widget.style),
          child: Padding(
            padding: widget.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null && !widget.iconOnRight)
                  Padding(
                    padding:
                        widget.iconOnly ? EdgeInsets.zero : widget.iconPadding,
                    child: widget.icon,
                  ),
                if (!widget.iconOnly)
                  Expanded(
                    flex: widget.textFlex,
                    child: Text(
                      widget.textValue,
                      textAlign: widget.textAlign,
                      style: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ).merge(widget.textStyle),
                      ),
                    ),
                  ),
                if (widget.icon != null && widget.iconOnRight)
                  Padding(
                    padding: widget.iconOnly
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(right: 8.0),
                    child: widget.icon,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
