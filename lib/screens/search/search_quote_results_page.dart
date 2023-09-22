import "package:flutter/material.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/quote.dart";

class SearchQuoteResultsPage extends StatelessWidget {
  const SearchQuoteResultsPage({
    super.key,
    this.margin = EdgeInsets.zero,
    this.quoteResults = const [],
    this.onTapQuote,
  });

  /// Space around this widget.
  final EdgeInsets margin;

  /// List of quotes results.
  final List<Quote> quoteResults;

  /// Callback fired when quote name is tapped.
  final void Function(Quote quote)? onTapQuote;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: margin,
      sliver: SliverList.builder(
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = quoteResults[index];
          return SearchQuoteText(
            quote: quote,
            onTapQuote: onTapQuote,
          );
        },
        itemCount: quoteResults.length,
      ),
    );
  }
}
