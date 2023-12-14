import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";

class SnackbarDraft extends StatelessWidget {
  /// A snackbar to indicate that the quote has been saved as a draft.
  /// A "propose" button is displayed on the right
  /// to submit the quote for review.
  ///
  /// [quote] The quote to propose for validation (if the action is taken).
  const SnackbarDraft({
    super.key,
    required this.quote,
  });

  /// The quote to propose for validation (if the action is taken).
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    return Padding(
      padding: const EdgeInsets.only(left: 90.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 24.0),
            child: Icon(TablerIcons.check),
          ),
          Expanded(
            flex: 0,
            child: Text.rich(
              TextSpan(
                text: "quote.save.draft.success".tr(),
                children: [
                  TextSpan(
                    text: " ${"quote.save.draft.validation".tr()}",
                  ),
                ],
              ),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 16.0,
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
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextButton(
              onPressed: () {
                QuoteActions.proposeQuote(
                  quote: quote,
                  userId: userFirestoreSignal.value.id,
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
