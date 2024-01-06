import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/draft_quote_text.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:unicons/unicons.dart";

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
          final DraftQuote quote = quotes[index];
          return ContextMenuWidget(
            child: DraftQuoteText(
              draftQuote: quote,
              tiny: isMobileSize,
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
            menuProvider: (MenuRequest menuRequest) {
              return Menu(
                children: [
                  MenuAction(
                    callback: () => onTap?.call(quote),
                    title: "quote.edit.name".tr(),
                    image: MenuImage.icon(UniconsLine.edit_alt),
                    attributes: const MenuActionAttributes(),
                  ),
                  MenuAction(
                    callback: () => onDelete?.call(quote),
                    title: "quote.delete.name".tr(),
                    image: MenuImage.icon(UniconsLine.trash),
                    attributes: const MenuActionAttributes(destructive: true),
                  ),
                  if (onValidate != null)
                    MenuAction(
                      callback: () => onValidate?.call(quote),
                      title: "quote.validate.name".tr(),
                      image: MenuImage.icon(UniconsLine.check),
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
