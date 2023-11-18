import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class ShowcaseText extends StatefulWidget {
  const ShowcaseText({
    super.key,
    required this.textValue,
    this.isDark = false,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(2.0),
    this.onTap,
    this.docId = "",
    this.index = 0,
  });

  /// Whether to adapt UI to dark theme.
  final bool isDark;

  /// Adapt UI to mobile size.
  final bool isMobileSize;

  /// Index.
  final int index;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Padding around the text.
  final EdgeInsets padding;

  // Callback fired when text is tapped.
  final void Function()? onTap;

  /// Document ID for hero animation transition.
  final String docId;

  /// Text value.
  final String textValue;

  @override
  State<ShowcaseText> createState() => _ShowcaseTextState();
}

class _ShowcaseTextState extends State<ShowcaseText> {
  Color? _foregroundColor = Colors.black;
  Color? _initialForegroundColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final Color? fColor = Theme.of(context).textTheme.bodyMedium?.color;
    _initialForegroundColor = widget.index % 2 == 0
        ? fColor?.withOpacity(0.4)
        : fColor?.withOpacity(0.8);

    return Padding(
      padding: widget.margin,
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
        onHover: (bool isHover) {
          if (isHover) {
            setState(() {
              _foregroundColor = Constants.colors.getRandomFromPalette(
                withGoodContrast: !widget.isDark,
              );
            });
            return;
          }

          setState(() => _foregroundColor = _initialForegroundColor);
        },
        child: Padding(
          padding: widget.padding,
          child: Hero(
            tag: widget.docId,
            child: Text(
              widget.textValue,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: widget.isMobileSize ? 32.0 : 24.0,
                  fontWeight:
                      widget.isMobileSize ? FontWeight.w300 : FontWeight.w400,
                  color: _foregroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
