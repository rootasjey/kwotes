import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/components/texts/draft_quote_text.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_quote_text_magnitude.dart";
import "package:super_context_menu/super_context_menu.dart";

/// Body component page displaying a user quotes in validation.
class DraftsPageBody extends StatelessWidget {
  const DraftsPageBody({
    super.key,
    required this.draftQuotes,
    this.animateList = true,
    this.isDark = false,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.onCopyFrom,
    this.onDelete,
    this.onEdit,
    this.onSubmit,
    this.onTap,
  });

  /// Animate list's items if true.
  final bool animateList;

  /// True if the page is mobile size.
  final bool isDark;

  /// Adapt user interface to tiny screens if true.
  final bool isMobileSize;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// List of quotes in favourites.
  final List<DraftQuote> draftQuotes;

  /// Callback fired to validate a draft quote.
  /// It will then be added to the list of published quotes.
  final void Function(DraftQuote quote)? onCopyFrom;

  /// Callback fired to delete a quote in validation.
  final void Function(DraftQuote quote)? onDelete;

  /// Callback fired to navigate to the edit page with the selected quote.
  final void Function(DraftQuote quote)? onEdit;

  /// Callback fired when a quote must be submitted for validation.
  final void Function(DraftQuote quote)? onSubmit;

  /// Callback fired when a quote is tapped.
  final void Function(DraftQuote quote)? onTap;

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
          final DraftQuote draftQuote = draftQuotes[index];

          return ContextMenuWidget(
              child: DraftQuoteText(
                draftQuote: draftQuote,
                margin: const EdgeInsets.only(bottom: 0.0),
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
                return ContextMenuComponents.draftMenuProvider(
                  context,
                  draftQuote: draftQuote,
                  onDelete: onDelete,
                  onCopyFrom: onCopyFrom,
                  onEdit: onEdit,
                  onSubmit: onSubmit,
                );
              });
        },
        itemCount: draftQuotes.length,
      ),
    );
  }
}
