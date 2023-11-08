import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote.dart";

class RandomQuoteText extends StatelessWidget {
  const RandomQuoteText({
    super.key,
    required this.quote,
    this.foregroundColor,
    this.onTap,
  });

  /// Quote to display.
  final Quote quote;

  /// Foreground text color.
  final Color? foregroundColor;

  /// Callback fired when the quote is tapped.
  final void Function(Quote quote)? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap != null ? () => onTap?.call(quote) : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
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
            Text(
              quote.name,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  color: foregroundColor?.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
