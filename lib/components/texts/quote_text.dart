import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";

class QuoteText extends StatefulWidget {
  /// A component to display a quote (exclusively) as its text.
  const QuoteText({
    super.key,
    required this.quote,
    this.margin = EdgeInsets.zero,
    this.onTap,
  });

  /// Space around this widget.
  final EdgeInsets margin;

  /// Quote to display.
  final Quote quote;

  /// Callback fired when quote is tapped.
  final void Function(Quote quote)? onTap;

  @override
  State<QuoteText> createState() => _QuoteTextState();
}

class _QuoteTextState extends State<QuoteText> {
  Color? _hoverBackgroundColor = Colors.transparent;
  Color _shadowColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    final Topic topic = widget.quote.topics.isEmpty
        ? Topic.empty()
        : Constants.colors.topics.firstWhere(
            (Topic x) => x.name == widget.quote.topics.first,
            orElse: () => Topic.empty(),
          );

    _hoverBackgroundColor = topic.color;
  }

  @override
  Widget build(BuildContext context) {
    final Quote quote = widget.quote;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final String quoteName =
        quote.name.isEmpty ? "quote.empty.name".tr() : quote.name;

    final FontStyle fontStyle =
        quote.name.isEmpty ? FontStyle.italic : FontStyle.normal;

    final Color? color = quote.name.isEmpty
        ? foregroundColor?.withOpacity(0.4)
        : foregroundColor?.withOpacity(0.8);

    return Padding(
      padding: widget.margin,
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: widget.onTap != null ? () => widget.onTap?.call(quote) : null,
        onHover: (bool isHover) {
          if (isHover) {
            setState(() {
              _shadowColor =
                  _hoverBackgroundColor?.withOpacity(0.8) ?? Colors.transparent;
            });

            return;
          }

          setState(() {
            _shadowColor = Colors.transparent;
          });
        },
        child: Text(
          quoteName,
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 42.0,
              fontWeight: FontWeight.w200,
              color: color,
              fontStyle: fontStyle,
              shadows: [
                Shadow(
                  blurRadius: 0.5,
                  offset: const Offset(-1.0, 1.0),
                  color: _shadowColor,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
