import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/quote_text.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:unicons/unicons.dart";

class PublishedPageBody extends StatelessWidget {
  const PublishedPageBody({
    super.key,
    required this.quotes,
    this.isDark = false,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.onChangeLanguage,
    this.onCopy,
    this.onDelete,
    this.onEdit,
    this.onTap,
  });

  /// Adapt UI for mobile size if true.
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

  /// Callback fired when a quote is going to be deleted.
  final void Function(Quote quote)? onDelete;

  /// Callback fired when a quote is going to be edited.
  final void Function(Quote quote)? onEdit;

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
              margin: const EdgeInsets.only(bottom: 0.0),
              onTap: onTap,
              tiny: isMobileSize,
            ),
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
                if (onEdit != null)
                  MenuAction(
                    callback: () => onEdit?.call(quote),
                    title: "quote.edit.name".tr(),
                    image: MenuImage.icon(UniconsLine.edit_alt),
                  ),
                if (onChangeLanguage != null)
                  ContextMenuComponents.changeLanguage(
                    context,
                    quote: quote,
                    onChangeLanguage: onChangeLanguage,
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
