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
    this.initialForegroundColor,
  });

  /// Whether to adapt UI to dark theme.
  final bool isDark;

  /// Adapt UI to mobile size.
  final bool isMobileSize;

  /// Initial foreground color.
  final Color? initialForegroundColor;

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
  /// Color on hover.
  Color? _accentColor;

  /// Current text foreground color.
  Color? _foregroundColor = Colors.black;

  /// Initial text foreground color.
  Color? _initialForegroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    initProps();
  }

  /// Initializes properties.
  void initProps() {
    _accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: !widget.isDark,
    );

    setState(() {
      _initialForegroundColor = widget.initialForegroundColor;
      _foregroundColor = _initialForegroundColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialForegroundColor != widget.initialForegroundColor) {
      _initialForegroundColor = widget.initialForegroundColor;
      initProps();
    }

    return Padding(
      padding: widget.margin,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: _foregroundColor?.withOpacity(0.4),
        hoverColor: Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
        onHover: (bool isHover) {
          setState(() {
            _foregroundColor = isHover ? _accentColor : _initialForegroundColor;
          });
        },
        child: Padding(
          padding: widget.padding,
          child: Hero(
            tag: widget.docId,
            child: Text(
              widget.textValue,
              style: Utils.calligraphy.body4(
                textStyle: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w200,
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
