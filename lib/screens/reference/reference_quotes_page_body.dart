import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/quote.dart";

class ReferenceQuotesPageBody extends StatelessWidget {
  const ReferenceQuotesPageBody({
    super.key,
    this.isMobileSize = false,
    this.accentColor,
    this.quotes = const [],
    this.onTapBackButton,
    this.onTapQuote,
  });

  /// Whether to use mobile layout.
  final bool isMobileSize;

  /// Random accent color for some UI elements.
  final Color? accentColor;

  /// List of quotes.
  final List<Quote> quotes;

  /// Callback fired when back button is tapped.
  final void Function()? onTapBackButton;

  /// Callback fired when quote is tapped.
  final void Function(Quote quote)? onTapQuote;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    if (quotes.isEmpty) {
      return EmptyView.quotes(
        context,
        title: "${"quote.empty.there".tr()}\n",
        description:
            "${"quote.empty.reference".tr()}\n${"language.this_parenthesis".tr()}",
        buttonTextValue: "back".tr(),
        onTapBackButton: onTapBackButton,
        foregroundColor: foregroundColor,
        accentColor: accentColor,
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 24.0,
        left: 24.0,
        right: 24.0,
        bottom: 54.0,
      ),
      sliver: SliverList.builder(
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = quotes[index];
          return SearchQuoteText(
            quote: quote,
            onTapQuote: onTapQuote,
            tiny: isMobileSize,
            margin: const EdgeInsets.only(bottom: 16.0),
          );
        },
        itemCount: quotes.length,
      ),
    );
  }
}
