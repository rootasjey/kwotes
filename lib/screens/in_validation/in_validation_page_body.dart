import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/swipe_from_left_container.dart";
import "package:kwotes/components/swipe_from_right_container.dart";
import "package:kwotes/components/texts/draft_quote_text.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_quote_text_magnitude.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:swipeable_tile/swipeable_tile.dart";

/// Body component page displaying quotes in validation.
class InValidationPageBody extends StatelessWidget {
  const InValidationPageBody({
    super.key,
    required this.quotes,
    this.animateList = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.onTap,
    this.onDelete,
    this.onValidate,
  });

  /// Animate list's items if true.
  final bool animateList;

  /// Adapt UI for dark mode if true.
  final bool isDark;

  /// Adapt UI for mobile size if true.
  final bool isMobileSize;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// List of quotes in favourites.
  final List<DraftQuote> quotes;

  /// Callback fired to delete a quote in validation.
  final void Function(DraftQuote quote)? onDelete;

  /// Callback fired when a quote is tapped.
  final void Function(Quote quote)? onTap;

  /// Callback fired to validate a draft quote.
  /// It will then be added to the list of published quotes.
  final void Function(DraftQuote quote)? onValidate;

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
        title: "in_validation.empty.name".tr(),
        description: "in_validation.empty.description".tr(),
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
          final DraftQuote quote = quotes[index];
          return ContextMenuWidget(
            child: SwipeableTile(
              isElevated: false,
              swipeThreshold: 0.3,
              direction: onValidate != null
                  ? SwipeDirection.horizontal
                  : SwipeDirection.endToStart,
              color: Theme.of(context).scaffoldBackgroundColor,
              key: ValueKey(quote.id),
              confirmSwipe: (SwipeDirection direction) {
                if (direction == SwipeDirection.endToStart) {
                  return Future.value(true);
                } else if (direction == SwipeDirection.startToEnd &&
                    onValidate != null) {
                  onValidate?.call(quote);
                  return Future.value(false);
                }

                return Future.value(false);
              },
              onSwiped: (SwipeDirection direction) {
                if (direction == SwipeDirection.endToStart) {
                  onDelete?.call(quote);
                } else if (direction == SwipeDirection.startToEnd) {
                  onValidate?.call(quote);
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
                  builder: (
                    BuildContext context,
                    Widget? child,
                  ) {
                    final bool triggered = progress.value >= 0.3;

                    if (triggered && !vibrated) {
                      Utils.graphic.slideVibration();

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

                      return SwipeFromRightContainer(
                        color: color,
                        iconData: TablerIcons.trash,
                      );
                    } else if (direction == SwipeDirection.startToEnd) {
                      final Color color = triggered
                          ? Constants.colors.edit
                          : Constants.colors.edit.withOpacity(
                              Constants.colors.swipeStartOpacity,
                            );

                      return SwipeFromLeftContainer(
                        color: color,
                        iconData: TablerIcons.check,
                      );
                    }

                    return Container();
                  },
                );
              },
              child: DraftQuoteText(
                draftQuote: quote,
                contraints: const BoxConstraints(minHeight: 90.0),
                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                magnitude: isMobileSize
                    ? EnumQuoteTextMagnitude.medium
                    : EnumQuoteTextMagnitude.big,
                onTap: onTap,
              )
                  .animate()
                  .slideY(
                    begin: 0.8,
                    end: 0.0,
                    curve: Curves.decelerate,
                    duration: animateList ? 150.ms : 0.ms,
                  )
                  .fadeIn(),
            ),
            menuProvider: (MenuRequest menuRequest) {
              return Menu(
                children: [
                  MenuAction(
                    callback: () => onTap?.call(quote),
                    title: "quote.edit.name".tr(),
                    image: MenuImage.icon(TablerIcons.edit),
                    attributes: const MenuActionAttributes(),
                  ),
                  MenuAction(
                    callback: () => onDelete?.call(quote),
                    title: "quote.delete.name".tr(),
                    image: MenuImage.icon(TablerIcons.trash),
                    attributes: const MenuActionAttributes(destructive: true),
                  ),
                  if (onValidate != null)
                    MenuAction(
                      callback: () => onValidate?.call(quote),
                      title: "quote.validate.name".tr(),
                      image: MenuImage.icon(TablerIcons.check),
                    ),
                ],
              );
            },
          );
        },
        itemCount: quotes.length,
      ),
    );
  }
}
