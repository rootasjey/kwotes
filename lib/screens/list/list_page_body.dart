import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/quote_text.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";

/// Body component page displaying a user quote list content.
class ListPageBody extends StatelessWidget {
  const ListPageBody({
    super.key,
    required this.quotes,
    required this.userId,
    this.animateList = false,
    this.pageState = EnumPageState.idle,
    this.onRemove,
    this.onTap,
    this.onCopy,
    this.isMobileSize = false,
  });

  /// Animate list's items if true.
  final bool animateList;

  /// Adapt UI for mobile size.
  final bool isMobileSize;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// List of quotes in favourites.
  final List<Quote> quotes;

  /// Callback fired to copy a quote.
  final void Function(Quote quote)? onCopy;

  /// Callback fired to remove a quote from the list.
  final void Function(Quote quote)? onRemove;

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
        margin: const EdgeInsets.only(left: 48.0, right: 72.0),
        title: "list.empty".tr(),
      );
    }

    return SliverPadding(
      padding: isMobileSize
          ? const EdgeInsets.only(left: 24.0, right: 24.0)
          : const EdgeInsets.only(left: 48.0, right: 72.0),
      sliver: SliverList.separated(
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            height: 54.0,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          final Quote quote = quotes[index];

          return ContextMenuWidget(
            child: QuoteText(
              quote: quote,
              margin: const EdgeInsets.only(bottom: 0.0),
              onTap: onTap,
              tiny: isMobileSize,
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
              return Menu(
                children: [
                  MenuAction(
                    title: "quote.remove.name".tr(),
                    callback: () => onRemove?.call(quote),
                    image: MenuImage.icon(TablerIcons.square_rounded_minus),
                  ),
                  MenuAction(
                    callback: () => onCopy?.call(quote),
                    title: "quote.copy.name".tr(),
                    image: MenuImage.icon(TablerIcons.copy),
                  ),
                  ContextMenuComponents.addToList(
                    context,
                    quote: quote,
                    userId: userId,
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
