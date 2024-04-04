import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/quote_text.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_quote_text_magnitude.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:swipeable_tile/swipeable_tile.dart";
import "package:vibration/vibration.dart";

class PublishedPageBody extends StatelessWidget {
  const PublishedPageBody({
    super.key,
    required this.quotes,
    this.isDark = false,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.onOpenAddToList,
    this.onChangeLanguage,
    this.onCopy,
    this.onCopyQuoteUrl,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.onShareImage,
    this.onShareLink,
    this.onShareText,
    this.userId = "",
  });

  /// Adapt UI for dark mode if true.
  final bool isDark;

  /// True if the page is mobile size.
  final bool isMobileSize;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// List of quotes in favourites.
  final List<Quote> quotes;

  /// Callback fired when a new language is selected for a specific quote.
  final void Function(Quote quote, String language)? onChangeLanguage;

  /// Callback fired to copy a quote.
  final void Function(Quote quote)? onCopy;

  /// Callback fired to copy a quote's url.
  final void Function(Quote quote)? onCopyQuoteUrl;

  /// Callback fired when a quote is going to be deleted.
  final void Function(Quote quote)? onDelete;

  /// Callback fired when a quote is going to be edited.
  final void Function(Quote quote)? onEdit;

  /// Callback fired to add a quote to a list.
  final void Function(Quote quote)? onOpenAddToList;

  /// Callback fired to share a quote's image.
  final void Function(Quote quote)? onShareImage;

  /// Callback fired to share a quote's name.
  final void Function(Quote quote)? onShareText;

  /// Callback fired to share a quote's link.
  final void Function(Quote quote)? onShareLink;

  /// Callback fired when a quote is tapped.
  final void Function(Quote quote)? onTap;

  /// User id.
  final String userId;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "loading".tr(),
      );
    }

    final EdgeInsets margin = isMobileSize
        ? const EdgeInsets.only(top: 6.0, left: 24.0, right: 24.0)
        : const EdgeInsets.only(top: 54.0, left: 48.0, right: 72.0);

    if (quotes.isEmpty) {
      return EmptyView(
        title: "published.empty.name".tr(),
        description: "published.empty.description".tr(),
        margin: margin,
      );
    }

    return SliverPadding(
      padding: margin,
      sliver: SliverList.separated(
        separatorBuilder: (BuildContext context, int index) {
          return isDark
              ? const Divider(height: 54.0, color: Colors.white12)
              : const Divider(height: 54.0, color: Colors.black12);
        },
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = quotes[index];

          return ContextMenuWidget(
            child: SwipeableTile(
              isElevated: false,
              swipeThreshold: 0.3,
              direction: onEdit != null
                  ? SwipeDirection.horizontal
                  : SwipeDirection.startToEnd,
              color: Theme.of(context).scaffoldBackgroundColor,
              key: ValueKey(quote.id),
              confirmSwipe: (SwipeDirection direction) {
                if (direction == SwipeDirection.endToStart && onEdit != null) {
                  onEdit?.call(quote);
                  return Future.value(false);
                } else if (direction == SwipeDirection.startToEnd) {
                  onOpenAddToList?.call(quote);
                  return Future.value(false);
                }

                return Future.value(false);
              },
              onSwiped: (SwipeDirection direction) {
                if (direction == SwipeDirection.endToStart && onEdit != null) {
                  onEdit?.call(quote);
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
                            Vibration.vibrate(amplitude: 12);
                          }
                        });

                        vibrated = true;
                      } else if (!triggered) {
                        vibrated = false;
                      }

                      if (direction == SwipeDirection.endToStart) {
                        final Color color = triggered
                            ? Constants.colors.edit
                            : Constants.colors.edit.withOpacity(
                                Constants.colors.swipeStartOpacity,
                              );

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: color,
                          ),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 24.0),
                              child: Icon(
                                TablerIcons.edit,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      } else if (direction == SwipeDirection.startToEnd) {
                        final Color color = triggered
                            ? Constants.colors.lists
                            : Constants.colors.lists.withOpacity(
                                Constants.colors.swipeStartOpacity,
                              );

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: color,
                          ),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 24.0),
                              child: Icon(
                                TablerIcons.plus,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      return Container();
                    });
              },
              child: QuoteText(
                quote: quote,
                margin: const EdgeInsets.only(bottom: 0.0),
                onTap: onTap,
                magnitude: isMobileSize
                    ? EnumQuoteTextMagnitude.medium
                    : EnumQuoteTextMagnitude.big,
              ),
            ),
            menuProvider: (MenuRequest menuRequest) {
              return ContextMenuComponents.quoteMenuProvider(
                context,
                quote: quote,
                onChangeLanguage: onChangeLanguage,
                onCopyQuote: onCopy,
                onCopyQuoteUrl: onCopyQuoteUrl,
                onDelete: onDelete,
                onEdit: onEdit,
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
