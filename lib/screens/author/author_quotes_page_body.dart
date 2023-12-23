import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";

class AuthorQuotesPageBody extends StatelessWidget {
  const AuthorQuotesPageBody({
    super.key,
    this.isDark = false,
    this.isMobileSize = false,
    this.accentColor,
    this.onDoubleTapQuote,
    this.onTapQuote,
    this.onTapBackButton,
    this.quotes = const [],
    this.pageState = EnumPageState.idle,
    this.onCopyQuoteUrl,
    this.onShareImage,
    this.onShareLink,
    this.onShareText,
  });

  /// Adapt UI for dark mode.
  final bool isDark;

  /// Whether to use mobile layout.
  final bool isMobileSize;

  /// Accent color.
  final Color? accentColor;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  final void Function(Quote quote)? onCopyQuoteUrl;

  /// Callback fired when quote is double tapped.
  final void Function(Quote quote)? onDoubleTapQuote;

  /// Callback fired when image is shared.
  final void Function(Quote quote)? onShareImage;

  /// Callback fired when image is shared.
  final void Function(Quote quote)? onShareLink;

  /// Callback fired when image is shared.
  final void Function(Quote quote)? onShareText;

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

    if (pageState == EnumPageState.idle && quotes.isEmpty) {
      return EmptyView.quotes(
        context,
        title: "${"quote.empty.there".tr()}\n",
        description: "language.this_parenthesis".tr(),
        buttonTextValue: "back".tr(),
        onTapBackButton: onTapBackButton,
        foregroundColor: foregroundColor,
        accentColor: accentColor,
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        top: 48.0,
        left: isMobileSize ? 24.0 : 48.0,
        right: 24.0,
        bottom: 54.0,
      ),
      sliver: SliverList.separated(
        separatorBuilder: (BuildContext context, int index) {
          return isDark
              ? const Divider(height: 54.0, color: Colors.white12)
              : const Divider(height: 54.0, color: Colors.black12);
        },
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = quotes[index];
          return SearchQuoteText(
            quote: quote,
            onDoubleTapQuote: onDoubleTapQuote,
            onTapQuote: onTapQuote,
            tiny: isMobileSize,
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
          );
        },
        itemCount: quotes.length,
      ),
    );
  }
}
