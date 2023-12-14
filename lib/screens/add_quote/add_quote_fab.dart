import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/quote.dart";

class AddQuoteFAB extends StatelessWidget {
  const AddQuoteFAB({
    super.key,
    required this.quote,
    this.canManageQuotes = false,
    this.isMobileSize = false,
    this.fabForegroundColor,
    this.fabBackgroundColor,
    this.isQuoteValid = false,
    this.onLongPress,
    this.onPressed,
  });

  /// Can validate quotes if this is true.
  final bool canManageQuotes;

  /// Check if the quote's required properties are valid (name & topics).
  final bool isQuoteValid;

  /// Adapt user interface to moile size if true.
  final bool isMobileSize;

  /// Foreground color of the fab.
  final Color? fabForegroundColor;

  /// Background color of the fab.
  final Color? fabBackgroundColor;

  /// Callback fired when this button is tapped.
  final void Function()? onPressed;

  /// Callback fired when this button is long pressed.
  final void Function()? onLongPress;

  /// Quote we're editing.
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    if (isMobileSize) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: fabBackgroundColor,
            foregroundColor: fabForegroundColor,
            tooltip: isQuoteValid
                ? "quote.submit.ok".tr()
                : "quote.submit.required".tr(),
            elevation: 0.0,
            disabledElevation: 0.0,
            hoverElevation: 4.0,
            focusElevation: 0.0,
            highlightElevation: 0.0,
            mini: true,
            splashColor: Colors.white,
            child: const Icon(TablerIcons.device_floppy),
          ),
        ),
      );
    }
    return GestureDetector(
      onLongPress: onLongPress,
      child: FloatingActionButton.extended(
        elevation: 0.0,
        disabledElevation: 0.0,
        hoverElevation: 4.0,
        focusElevation: 0.0,
        highlightElevation: 0.0,
        splashColor: Colors.white,
        tooltip: isQuoteValid ? "" : "quote.submit.required".tr(),
        onPressed: isQuoteValid ? onPressed : null,
        backgroundColor: fabBackgroundColor,
        label: Text(
          getLabel(),
          style: Utils.calligraphy.body(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        icon: const Icon(TablerIcons.device_floppy),
        foregroundColor: fabForegroundColor,
      ),
    );
  }

  String getLabel() {
    if (quote is! DraftQuote) {
      return "quote.update.name".tr();
    }

    final DraftQuote draft = quote as DraftQuote;

    if (!draft.inValidation) {
      return "quote.save.name".tr();
    }

    return "quote.save.name".tr();
  }
}
