import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/screens/search/search_quote_text.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:swipeable_tile/swipeable_tile.dart";
import "package:vibration/vibration.dart";
import "package:wave_divider/wave_divider.dart";

class SearchQuoteResultsPage extends StatelessWidget {
  const SearchQuoteResultsPage({
    super.key,
    this.isDark = false,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.quoteResults = const [],
    this.onOpenAddToList,
    this.onTapQuote,
    this.onToggleLike,
    this.userId = "",
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

  /// Callback fired to add a quote to a list.
  final void Function(Quote quote)? onOpenAddToList;

  /// Callback fired when quote name is tapped.
  final void Function(Quote quote)? onTapQuote;

  /// Callback fired to like or unlike a quote.
  final void Function(Quote quote)? onToggleLike;

  /// User ID.
  /// Used to check if user can add a quote to a list or like a quote.
  /// If user is not logged in, this will be empty.
  /// Filled otherwise.
  final String userId;

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
                        Vibration.vibrate(amplitude: 12);
                      }
                    });

                    vibrated = true;
                  } else if (!triggered) {
                    vibrated = false;
                  }

                  if (direction == SwipeDirection.endToStart) {
                    final Color color = triggered
                        ? Constants.colors.delete
                        : Constants.colors.delete.withOpacity(
                            Constants.colors.swipeStartOpacity,
                          );

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: color,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 24.0),
                          child: Icon(
                            quote.starred
                                ? TablerIcons.heart_filled
                                : TablerIcons.heart,
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
                },
              );
            },
            child: SearchQuoteText(
              quote: quote,
              onTapQuote: onTapQuote,
              tiny: isMobileSize,
              margin: const EdgeInsets.only(bottom: 16.0),
              textColor: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.8),
              quoteMenuProvider: (MenuRequest menuRequest) {
                return ContextMenuComponents.quoteMenuProvider(
                  context,
                  quote: quote,
                );
              },
            ),
          );
        },
        itemCount: quoteResults.length,
      ),
    );
  }
}
