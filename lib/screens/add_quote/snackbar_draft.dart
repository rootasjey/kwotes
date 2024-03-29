import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote.dart";

class SnackbarDraft extends StatelessWidget {
  /// A snackbar to indicate that the quote has been saved as a draft.
  /// A "propose" button is displayed on the right
  /// to submit the quote for review.
  ///
  /// [quote] The quote to propose for validation (if the action is taken).
  const SnackbarDraft({
    super.key,
    required this.quote,
    this.hideSubmitButton = false,
    this.isInValidation = false,
    this.isMobileSize = false,
    this.userId = "",
  });

  /// Don't display the "propose" button if true.
  final bool hideSubmitButton;

  /// Don't display the "submit" button if true.
  final bool isInValidation;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// The quote to propose for validation (if the action is taken).
  final Quote quote;

  /// Id of the current authenticated user.
  /// Empty if no user is authenticated.
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMobileSize)
            const Padding(
              padding: EdgeInsets.only(right: 24.0),
              child: Icon(TablerIcons.check),
            ),
          Expanded(
            flex: 1,
            child: Text.rich(
              TextSpan(
                text: "quote.save.draft.success".tr(),
                children: [
                  if (!isInValidation)
                    TextSpan(
                      text: " ${"quote.save.draft.validation".tr()}",
                    ),
                ],
              ),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: isMobileSize ? 14.0 : 16.0,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.6),
                ),
              ),
            ),
          ),
          if (!isInValidation && !hideSubmitButton)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextButton(
                onPressed: () {
                  QuoteActions.submitQuote(
                    quote: quote,
                    userId: userId,
                  );
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                style: TextButton.styleFrom(
                    textStyle: const TextStyle(
                  fontSize: 16.0,
                )),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "quote.submit.name".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(TablerIcons.send),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
