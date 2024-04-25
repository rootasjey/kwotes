import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/swipe_from_left_container.dart";
import "package:kwotes/components/swipe_from_right_container.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:swipeable_tile/swipeable_tile.dart";
import "package:vibration/vibration.dart";

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
    this.onOpenAddToList,
    this.onToggleLike,
    this.userId = "",
  });

  /// Adapt UI for dark mode.
  final bool isDark;

  /// Whether to use mobile layout.
  final bool isMobileSize;

  /// Accent color.
  final Color? accentColor;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Callback fired when quote is copied.
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

  /// Callback fired to add a quote to a list.
  final void Function(Quote quote)? onOpenAddToList;

  /// Callback fired to like or unlike a quote.
  final void Function(Quote quote)? onToggleLike;

  /// List of quotes.
  final List<Quote> quotes;

  /// User ID.
  /// Used to check if user can add a quote to a list or like a quote.
  /// If user is not logged in, this will be empty.
  /// Filled otherwise.
  final String userId;

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
          return SwipeableTile(
            isElevated: false,
            swipeThreshold: 0.3,
            direction: userId.isEmpty
                ? SwipeDirection.none
                : SwipeDirection.horizontal,
            color: Theme.of(context).scaffoldBackgroundColor,
            key: ValueKey(quote.id),
            confirmSwipe: (SwipeDirection direction) {
              if (direction == SwipeDirection.endToStart) {
                onToggleLike?.call(quote);
                return Future.value(false);
              } else if (direction == SwipeDirection.startToEnd) {
                onOpenAddToList?.call(quote);
                return Future.value(false);
              }

              return Future.value(false);
            },
            onSwiped: (SwipeDirection direction) {
              if (direction == SwipeDirection.endToStart) {
                onToggleLike?.call(quote);
              } else if (direction == SwipeDirection.startToEnd) {
                onOpenAddToList?.call(quote);
              }
            },
            backgroundBuilder: (
              BuildContext context,
              SwipeDirection direction,
              AnimationController progress,
            ) {
              bool vibrated = false;

              return AnimatedBuilder(
                animation: progress,
                builder: (BuildContext context, Widget? child) {
                  final bool triggered = progress.value >= 0.3;

                  if (triggered && !vibrated) {
                    Vibration.hasVibrator().then((bool? hasVibrator) {
                      if (hasVibrator ?? false) {
                        Vibration.vibrate(amplitude: 20, duration: 25);
                      }
                    });

                    vibrated = true;
                  } else if (!triggered) {
                    vibrated = false;
                  }

                  if (direction == SwipeDirection.endToStart) {
                    final Color color = triggered
                        ? Constants.colors.likes
                        : Constants.colors.likes.withOpacity(
                            Constants.colors.swipeStartOpacity,
                          );

                    return SwipeFromRightContainer(
                      color: color,
                      iconData: quote.starred
                          ? TablerIcons.heart_filled
                          : TablerIcons.heart,
                    );
                  } else if (direction == SwipeDirection.startToEnd) {
                    final Color color = triggered
                        ? Constants.colors.lists
                        : Constants.colors.lists.withOpacity(
                            Constants.colors.swipeStartOpacity,
                          );

                    return SwipeFromLeftContainer(
                      color: color,
                      iconData: TablerIcons.plus,
                    );
                  }

                  return Container();
                },
              );
            },
            child: SearchQuoteText(
              quote: quote,
              onDoubleTapQuote: onDoubleTapQuote,
              onTapQuote: onTapQuote,
              tiny: isMobileSize,
              constraints: const BoxConstraints(minHeight: 90.0),
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
            ),
          );
        },
        itemCount: quotes.length,
      ),
    );
  }
}
