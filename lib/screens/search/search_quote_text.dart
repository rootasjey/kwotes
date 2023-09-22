import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";

/// A component to display a quote (exclusively) as its text
/// (on the search results page).
class SearchQuoteText extends StatefulWidget {
  const SearchQuoteText({
    super.key,
    required this.quote,
    this.onTapQuote,
    this.textColor,
  });

  /// Text color.
  final Color? textColor;

  /// Quote to display.
  final Quote quote;

  /// Callback fired when quote is tapped.
  final void Function(Quote quote)? onTapQuote;

  @override
  State<SearchQuoteText> createState() => _SearchQuoteTextState();
}

class _SearchQuoteTextState extends State<SearchQuoteText> {
  /// Text shadow color.
  Color _textShadowColor = Colors.transparent;

  /// Topic color.
  Topic _topicColor = Topic.empty();

  @override
  void initState() {
    super.initState();
    _topicColor = Constants.colors.topics.firstWhere(
      (x) => x.name == widget.quote.topics.first,
      orElse: () => Topic.empty(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Quote quote = widget.quote;
    final void Function(Quote)? onTapQuote = widget.onTapQuote;
    final bool darkBrightness = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: onTapQuote != null ? () => onTapQuote.call(quote) : null,
        onHover: (bool isHover) {
          if (isHover) {
            setState(() {
              _textShadowColor = _topicColor.color;
            });
            return;
          }

          setState(() {
            _textShadowColor = Colors.transparent;
          });
        },
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            quote.name,
            textAlign: TextAlign.start,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: 42.0,
                fontWeight: FontWeight.w300,
                color: widget.textColor,
                backgroundColor:
                    darkBrightness ? null : _topicColor.color.withOpacity(0.2),
                shadows: [
                  Shadow(
                    blurRadius: 0.0,
                    offset: const Offset(-1.0, 1.0),
                    color: _textShadowColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
