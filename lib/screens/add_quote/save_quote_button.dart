import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/draft_quote.dart";
import "package:kwotes/types/quote.dart";

class SaveQuoteButton extends StatelessWidget {
  const SaveQuoteButton({
    super.key,
    required this.quote,
    this.canManageQuotes = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.isQuoteValid = false,
    this.useIcon = false,
    this.fabForegroundColor,
    this.fabBackgroundColor,
    this.margin = EdgeInsets.zero,
    this.onLongPress,
    this.onPressed,
  });

  /// Can validate quotes if this is true.
  final bool canManageQuotes;

  /// Use dark mode if true.
  final bool isDark;

  /// Check if the quote's required properties are valid (name & topics).
  final bool isQuoteValid;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Use icon if true.
  final bool useIcon;

  /// Foreground color of the fab.
  final Color? fabForegroundColor;

  /// Background color of the fab.
  final Color? fabBackgroundColor;

  /// Margin of the fab button.
  final EdgeInsets margin;

  /// Callback fired when this button is tapped.
  final void Function()? onPressed;

  /// Callback fired when this button is long pressed.
  final void Function()? onLongPress;

  /// Quote we're editing.
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: onPressed,
            onLongPress: onLongPress,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              foregroundColor: fabForegroundColor,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              elevation: 0.0,
            ),
            child: Wrap(
              spacing: 12.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  getLabel(),
                  style: Utils.calligraphy.body(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                if (useIcon) Icon(getIconData(), size: 18.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData getIconData() {
    if (quote is! DraftQuote) {
      return TablerIcons.upload;
    }

    final DraftQuote draft = quote as DraftQuote;

    if (!draft.inValidation) {
      return TablerIcons.device_floppy;
    }

    return TablerIcons.device_floppy;
  }

  String getLabel() {
    if (quote is! DraftQuote) {
      return "update.name".tr().toUpperCase();
    }

    final DraftQuote draft = quote as DraftQuote;

    if (!draft.inValidation) {
      return "save".tr().toUpperCase();
    }

    return "save".tr().toUpperCase();
  }
}
