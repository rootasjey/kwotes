import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class ShowcaseText extends StatefulWidget {
  const ShowcaseText({
    super.key,
    required this.textValue,
    this.margin = EdgeInsets.zero,
    this.foregroundColor,
    this.onTap,
    this.docId = "",
  });

  /// Text color.
  final Color? foregroundColor;

  /// Space around this widget.
  final EdgeInsets margin;

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
      padding: const EdgeInsets.all(0.0),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        onHover: (bool isHover) {
          if (isHover) {
            setState(() {
              _foregroundColor = Constants.colors.getRandomFromPalette();
            });
            return;
          }

          setState(() {
            _foregroundColor = widget.foregroundColor;
          });
        },
        child: Hero(
          tag: widget.docId,
          child: Text(
            widget.textValue,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w400,
                color: _foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
