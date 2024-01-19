import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/quote_text.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_quote_text_magnitude.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";
import "package:super_context_menu/super_context_menu.dart";

/// Body component page displaying a user quote list content.
class ListPageBody extends StatelessWidget {
  const ListPageBody({
    super.key,
    required this.quotes,
    required this.userId,
    this.animateList = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.onCopyQuote,
    this.onCopyQuoteUrl,
    this.onDoubleTap,
    this.onRemoveFromList,
    this.onShareImage,
    this.onShareText,
    this.onShareLink,
    this.onTap,
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
  final void Function(Quote quote)? onCopyQuote;

  /// Callback fired to copy a quote's url.
  final void Function(Quote quote)? onCopyQuoteUrl;

  /// Callback fired to double tap a quote.
  final void Function(Quote quote)? onDoubleTap;

  /// Callback fired to remove a quote from the list.
  final void Function(Quote quote)? onRemoveFromList;

  /// Callback fired to share a quote's image.
  final void Function(Quote quote)? onShareImage;

  /// Callback fired to share a quote's name.
  final void Function(Quote quote)? onShareText;

  /// Callback fired to share a quote's link.
  final void Function(Quote quote)? onShareLink;

  /// Callback fired when a quote is tapped.
  final void Function(Quote quote)? onTap;

  /// User id.
  /// Required to add a quote to a user list (in context menu).
  final String userId;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "loading".tr(),
      );
    }

    if (quotes.isEmpty) {
      return EmptyView(
        margin: isMobileSize
            ? const EdgeInsets.symmetric(horizontal: 24.0)
            : const EdgeInsets.symmetric(horizontal: 48.0),
        title: "list.empty.name".tr(),
        description: "list.empty.description".tr(),
      );
    }

    return SliverPadding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 6.0, left: 24.0, right: 24.0)
          : const EdgeInsets.only(top: 6.0, left: 48.0, right: 72.0),
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
              onDoubleTap: onDoubleTap,
              onTap: onTap,
              magnitude: isMobileSize
                  ? EnumQuoteTextMagnitude.medium
                  : EnumQuoteTextMagnitude.big,
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
              final Topic topic = Constants.colors.topics.firstWhere(
                (Topic x) => x.name == quote.topics.first,
                orElse: () => Topic.empty(),
              );

              return ContextMenuComponents.quoteMenuProvider(
                context,
                quote: quote,
                onCopyQuote: onCopyQuote,
                onCopyQuoteUrl: onCopyQuoteUrl,
                onRemoveFromList: onRemoveFromList,
                onShareImage: onShareImage,
                onShareText: onShareText,
                onShareLink: onShareLink,
                selectedColor: topic.color,
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
