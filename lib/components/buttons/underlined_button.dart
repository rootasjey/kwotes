import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class UnderlinedButton extends StatefulWidget {
  /// Creates an underlined button.
  const UnderlinedButton({
    super.key,
    required this.textValue,
    this.accentColor = Colors.blue,
    this.onPressed,
    this.onLongPressed,
    this.style,
  });

  /// Color of the button on hover.
  final Color accentColor;

  /// Callback when button is pressed.
  final void Function()? onPressed;

  /// Callback when button is long pressed.
  final void Function()? onLongPressed;

  /// Text value for the button.
  final String textValue;

  /// Style for this button.
  final ButtonStyle? style;

  @override
  State<UnderlinedButton> createState() => _UnderlinedButtonState();
}

class _UnderlinedButtonState extends State<UnderlinedButton> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    final Color? foreground = Theme.of(context).textTheme.bodyMedium?.color;
    final Color decorationColor = _isHover
        ? widget.accentColor
        : foreground?.withOpacity(0.6) ?? Colors.black;

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: widget.accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal: 4.0,
        ),
      ).merge(widget.style),
      onPressed: widget.onPressed,
      onLongPress: widget.onLongPressed,
      onHover: (bool isHover) {
        setState(() => _isHover = isHover);
      },
      child: Text(
        widget.textValue,
        style: Utils.calligraphy.body(
          textStyle: TextStyle(
            fontSize: 18.0,
            color: Colors.transparent,
            fontWeight: FontWeight.w200,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.solid,
            decorationColor: decorationColor,
            decorationThickness: _isHover ? 2.0 : 1.0,
            shadows: [
              Shadow(
                color: decorationColor,
                offset: const Offset(0, -5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
