import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/quote.dart";
import "package:unicons/unicons.dart";

class AddQuoteFAB extends StatelessWidget {
  const AddQuoteFAB({
    super.key,
    required this.quote,
    this.canManageQuotes = false,
    this.fabForegroundColor,
    this.fabBackgroundColor,
    this.isQuoteValid = false,
    this.onSubmitQuote,
  });

  /// Can validate quotes if this is true.
  final bool canManageQuotes;

  /// Check if the quote's required properties are valid (name & topics).
  final bool isQuoteValid;

  /// Foreground color of the fab.
  final Color? fabForegroundColor;

  /// Background color of the fab.
  final Color? fabBackgroundColor;

  /// Callback fired when this button is tapped.
  final void Function()? onSubmitQuote;

  /// Quote we're editing.
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      elevation: 0.0,
      disabledElevation: 0.0,
      hoverElevation: 4.0,
      focusElevation: 0.0,
      highlightElevation: 0.0,
      splashColor: Colors.white,
      tooltip:
          isQuoteValid ? "quote.submit.ok".tr() : "quote.submit.required".tr(),
      onPressed: isQuoteValid ? onSubmitQuote : null,
      backgroundColor: fabBackgroundColor,
      label: Text(
        getLabel(),
        style: Utils.calligraphy.body(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      icon: const Icon(UniconsLine.message),
      foregroundColor: fabForegroundColor,
    );
  }

  String getLabel() {
    if (quote is! DraftQuote) {
      return "quote.update.name".tr();
    }

    final DraftQuote draft = quote as DraftQuote;

    if (!draft.inValidation) {
      return "quote.submit.name".tr();
    }

    if (canManageQuotes) {
      return "quote.validate.name".tr();
    }

    return "quote.save.name".tr();
  }
}
