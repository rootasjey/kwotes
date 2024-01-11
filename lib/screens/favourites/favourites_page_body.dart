import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/quote_text.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";

class FavouritesPageBody extends StatelessWidget {
  /// Body part of favourites page.
  const FavouritesPageBody({
    super.key,
    required this.quotes,
    this.animateList = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.onCopy,
    this.onCopyUrl,
    this.onDoubleTap,
    this.onTap,
    this.onRemove,
    this.onShareImage,
    this.onShareText,
    this.onShareLink,
    this.userId = "",
  });

  /// Animate list's items if true.
  final bool animateList;

  /// Adapt UI for dark mode.
  final bool isDark;

  /// Adapt UI for mobile size.
  final bool isMobileSize;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// List of quotes in favourites.
  final List<Quote> quotes;

  /// Callback fired to copy a quote.
  final void Function(Quote quote)? onCopy;

  /// Callback fired to copy a quote's url.
  final void Function(Quote quote)? onCopyUrl;

  /// On double tap callback.
  final void Function(Quote quote)? onDoubleTap;

  /// On tap callback.
  final void Function(Quote quote)? onTap;

  /// Callback fired when a quote is unfavorited.
  final void Function(Quote quote)? onRemove;

  /// Callback fired to share a quote's image.
  final void Function(Quote quote)? onShareImage;

  /// Callback fired to share a quote's name.
  final void Function(Quote quote)? onShareText;

  /// Callback fired to share a quote's link.
  final void Function(Quote quote)? onShareLink;

  /// User's id.
  final String userId;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "loading".tr(),
      );
    }

    return SliverPadding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 6.0, left: 24.0, right: 24.0)
          : const EdgeInsets.only(top: 54.0, left: 48.0, right: 72.0),
      sliver: SliverList.separated(
        separatorBuilder: (BuildContext context, int index) {
          return isDark
              ? const Divider(height: 54.0, color: Colors.white12)
              : const Divider(height: 54.0, color: Colors.black12);
        },
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = quotes[index];

          return ContextMenuWidget(
            child: QuoteText(
              quote: quote,
              tiny: isMobileSize,
              margin: const EdgeInsets.only(bottom: 0.0),
              onTap: onTap,
              onDoubleTap: onDoubleTap,
            )
                .animate()
                .slideY(
                  begin: 0.8,
                  end: 0.0,
                  duration: animateList ? 150.ms : 0.ms,
                  curve: Curves.decelerate,
                )
                .fadeIn(),
            menuProvider: (MenuRequest menuRequest) {
              return ContextMenuComponents.quoteMenuProvider(
                context,
                quote: quote,
                onCopyQuote: onCopy,
                onCopyQuoteUrl: onCopyUrl,
                onRemoveFromFavourites: onRemove,
                onShareImage: onShareImage,
                onShareText: onShareText,
                onShareLink: onShareLink,
                userId: userId,
              );
            },
          );
        },
        itemCount: quotes.length,
      ),
    );
  }
}
