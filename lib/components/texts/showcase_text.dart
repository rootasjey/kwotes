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
    this.foregroundColor,
    this.onTap,
    this.docId = "",
  });

  /// Whether to adapt UI to dark theme.
  final bool isDark;

  /// Adapt UI to mobile size.
  final bool isMobileSize;

  /// Text color.
  final Color? foregroundColor;

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

  @override
  void initState() {
    super.initState();
    _foregroundColor = widget.foregroundColor;
  }

  @override
  Widget build(BuildContext context) {
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

          setState(() {
            _foregroundColor = widget.foregroundColor;
          });
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
