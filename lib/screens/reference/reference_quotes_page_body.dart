import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";

class ReferenceQuotesPageBody extends StatelessWidget {
  const ReferenceQuotesPageBody({
    super.key,
    this.isMobileSize = false,
    this.accentColor,
    this.pageState = EnumPageState.idle,
    this.quotes = const [],
    this.onCopyQuoteUrl,
    this.onDoubleTapQuote,
    this.onShareImage,
    this.onShareLink,
    this.onShareText,
    this.onTapBackButton,
    this.onTapQuote,
  });

  /// Whether to use mobile layout.
  final bool isMobileSize;

  /// Random accent color for some UI elements.
  final Color? accentColor;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// List of quotes.
  final List<Quote> quotes;

  final void Function(Quote quote)? onCopyQuoteUrl;

  /// Callback fired when quote is double tapped.
  final void Function(Quote quote)? onDoubleTapQuote;

  /// Callback fired when image is shared.
  final void Function(Quote quote)? onShareImage;

  /// Callback fired when image is shared.
  final void Function(Quote quote)? onShareLink;

  /// Callback fired when image is shared.
  final void Function(Quote quote)? onShareText;

  /// Callback fired when back button is tapped.
  final void Function()? onTapBackButton;

  /// Callback fired when quote is tapped.
  final void Function(Quote quote)? onTapQuote;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    if (pageState == EnumPageState.idle && quotes.isEmpty) {
      return EmptyView.quotes(
        context,
        title: "${"quote.empty.there".tr()}\n",
        description: "${"quote.empty.reference".tr()}\n"
            "${"language.this_parenthesis".tr()}",
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
            onDoubleTapQuote: onDoubleTapQuote,
            onTapQuote: onTapQuote,
            quoteMenuProvider: (MenuRequest menuRequest) {
              return ContextMenuComponents.quoteMenuProvider(
                context,
                quote: quote,
                onCopyQuote: onDoubleTapQuote,
                onCopyQuoteUrl: onCopyQuoteUrl,
                onShareImage: onShareImage,
                onShareLink: onShareLink,
                onShareText: onShareText,
              );
            },
            tiny: isMobileSize,
            margin: const EdgeInsets.only(bottom: 16.0),
          );
        },
        itemCount: quotes.length,
      ),
    );
  }
}
