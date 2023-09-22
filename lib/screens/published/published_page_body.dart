import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/quote_text.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:unicons/unicons.dart";

class PublishedPageBody extends StatelessWidget {
  const PublishedPageBody({
    super.key,
    this.pageState = EnumPageState.idle,
    required this.quotes,
    this.onTap,
    this.onCopy,
    this.onDelete,
  });

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// List of quotes in favourites.
  final List<Quote> quotes;

  /// Callback fired to copy a quote.
  final void Function(Quote quote)? onCopy;

  /// Callback fired when a quote is unfavorited.
  final void Function(Quote quote)? onDelete;

  /// Callback fired when a quote is tapped.
  final void Function(Quote quote)? onTap;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "loading".tr(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 48.0, right: 72.0),
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
            )
                .animate()
                .slideY(begin: 0.8, end: 0.0, curve: Curves.decelerate)
                .fadeIn(),
            menuProvider: (MenuRequest menuRequest) {
              return Menu(children: [
                MenuAction(
                  callback: () => onCopy?.call(quote),
                  title: "quote.copy.name".tr(),
                  image: MenuImage.icon(TablerIcons.copy),
                ),
                if (onDelete != null)
                  MenuAction(
                    callback: () => onDelete?.call(quote),
                    title: "quote.delete.name".tr(),
                    image: MenuImage.icon(UniconsLine.trash),
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
