import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/quote.dart";

class RandomQuoteText extends StatelessWidget {
  const RandomQuoteText({
    super.key,
    required this.quote,
    this.foregroundColor,
    this.onTapQuote,
    this.onTapAuthor,
  });

  /// Quote to display.
  final Quote quote;

  /// Foreground text color.
  final Color? foregroundColor;

  /// Callback fired when the quote is tapped.
  final void Function(Quote quote)? onTapQuote;

  /// Callback fired when the author is tapped.
  final void Function(Author author)? onTapAuthor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(4.0),
            onTap: onTapAuthor != null
                ? () => onTapAuthor?.call(quote.author)
                : null,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
                top: 4.0,
                right: 4.0,
                bottom: 2.0,
              ),
              child: Text(
                "— ${quote.author.name}",
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: foregroundColor?.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(4.0),
            onTap: onTapQuote != null ? () => onTapQuote?.call(quote) : null,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                quote.name,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    color: foregroundColor?.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
