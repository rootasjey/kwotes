import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class ColoredTextButton extends StatefulWidget {
  /// A stylized text button.
  const ColoredTextButton({
    super.key,
    required this.textValue,
    this.icon,
    this.iconOnly = false,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.style,
    this.onPressed,
    this.tooltip = "",
    this.textStyle,
    this.textAlign,
  });

  /// Only show icon for this button if true.
  final bool iconOnly;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Spacing around the text.
  final EdgeInsets padding;

  /// Callback fired when user taps this button.
  final void Function()? onPressed;

  /// Text value for this button.
  final String textValue;

  /// Tooltip for this button.
  final String tooltip;

  /// Style for this button.
  final ButtonStyle? style;

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

  /// Button's text color.
  Color? _hoverForegroundColor;

  /// Maximum number of iteration to find a suitable random color from palette.
  final int _maxIteration = 4;

  @override
  void initState() {
    super.initState();
    _hoverForegroundColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Tooltip(
      message: widget.tooltip,
      child: Padding(
        padding: widget.margin,
        child: TextButton(
          onPressed: widget.onPressed,
          onHover: (bool isHover) {
            setState(() {
              _isHover = isHover;
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: _isHover
                ? _hoverForegroundColor
                : foregroundColor?.withOpacity(0.6),
          ).merge(widget.style),
          child: Padding(
            padding: widget.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null)
                  Padding(
                    padding: widget.iconOnly
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(right: 8.0),
                    child: widget.icon,
                  ),
                if (!widget.iconOnly)
                  Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color? getRandomForegroundColor() {
    bool found = false;
    int currInteration = 0;
    Color? color;

    while (!found && currInteration < _maxIteration) {
      currInteration++;
      color = Constants.colors.getRandomFromPalette();
      found = color.computeLuminance() < 0.5;
    }

    if (!found) {
      color = Colors.blue;
    }

    return color;
  }
}