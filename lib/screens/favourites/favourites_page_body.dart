import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
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
    this.onDoubleTap,
    this.onTap,
    this.onRemove,
    this.onCopy,
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

  /// Callback fired when a quote is unfavorited.
  final void Function(Quote quote)? onRemove;

  /// On tap callback.
  final void Function(Quote quote)? onTap;

  /// On double tap callback.
  final void Function(Quote quote)? onDoubleTap;

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
              return Menu(children: [
                MenuAction(
                  callback: () => onCopy?.call(quote),
                  title: "quote.copy.name".tr(),
                  image: MenuImage.icon(TablerIcons.copy),
                ),
                MenuAction(
                  callback: () => onRemove?.call(quote),
                  title: "quote.favourite.remove.name".tr(),
                  image: MenuImage.icon(TablerIcons.heart_minus),
                ),
              ]);
            },
          );
        },
        itemCount: quotes.length,
      ),
    );
  }
}
