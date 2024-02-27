import "package:flutter/material.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:wave_divider/wave_divider.dart";

class SearchQuoteResultsPage extends StatelessWidget {
  const SearchQuoteResultsPage({
    super.key,
    this.isDark = false,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.quoteResults = const [],
    this.onTapQuote,
  });

  /// Adapt UI for dark mode if true.
  final bool isDark;

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
      padding: isMobileSize
          ? const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
            )
          : margin,
      sliver: SliverList.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: WaveDivider(
              waveHeight: 2.0,
              waveWidth: 5.0,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.2),
            ),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = quoteResults[index];
          return SearchQuoteText(
            quote: quote,
            onTapQuote: onTapQuote,
            tiny: isMobileSize,
            margin: const EdgeInsets.only(bottom: 16.0),
            quoteMenuProvider: (MenuRequest menuRequest) {
              return ContextMenuComponents.quoteMenuProvider(
                context,
                quote: quote,
              );
            },
          );
        },
        itemCount: quoteResults.length,
      ),
    );
  }
}
