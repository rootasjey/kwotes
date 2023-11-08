import "package:flutter/material.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/quote.dart";

class SearchQuoteResultsPage extends StatelessWidget {
  const SearchQuoteResultsPage({
    super.key,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.quoteResults = const [],
    this.onTapQuote,
  });

  /// True if this is a mobile size.
  /// Used to determine the size of the search input.
  final bool isMobileSize;

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
            tiny: isMobileSize,
            margin: const EdgeInsets.only(bottom: 16.0),
          );
        },
        itemCount: quoteResults.length,
      ),
    );
  }
}
