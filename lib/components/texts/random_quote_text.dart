import "dart:async";

import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";

class RandomQuoteText extends StatelessWidget {
  const RandomQuoteText({
    super.key,
    required this.quote,
    required this.quoteMenuProvider,
    required this.authorMenuProvider,
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

  /// Context menu provider for the quote.
  final FutureOr<Menu?> Function(MenuRequest menuRequest) quoteMenuProvider;

  /// Context menu provider for the author.
  final FutureOr<Menu?> Function(MenuRequest menuRequest) authorMenuProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContextMenuWidget(
            menuProvider: authorMenuProvider,
            child: InkWell(
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
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ContextMenuWidget(
            menuProvider: quoteMenuProvider,
            child: InkWell(
              borderRadius: BorderRadius.circular(4.0),
              onTap: () => onTapQuote?.call(quote),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  quote.name,
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: foregroundColor?.withOpacity(0.8),
                    ),
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
