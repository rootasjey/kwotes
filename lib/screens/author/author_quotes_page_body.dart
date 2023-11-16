import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/quote.dart";

class AuthorQuotesPageBody extends StatelessWidget {
  const AuthorQuotesPageBody({
    super.key,
    this.isMobileSize = false,
    this.accentColor,
    this.onTapQuote,
    this.onTapBackButton,
    this.quotes = const [],
  });

  /// Whether to use mobile layout.
  final bool isMobileSize;

  final Color? accentColor;

  /// Callback fired when quote is tapped.
  final void Function(Quote quote)? onTapQuote;

  /// Callback fired when back button is tapped.
  final void Function()? onTapBackButton;

  /// List of quotes.
  final List<Quote> quotes;

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
        left: 18.0,
        right: 18.0,
        bottom: 54.0,
      ),
      sliver: SliverList.separated(
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 64.0);
        },
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = quotes[index];
          return SearchQuoteText(
            quote: quote,
            onTapQuote: onTapQuote,
            tiny: isMobileSize,
          );
        },
        itemCount: quotes.length,
      ),
    );
  }
}
