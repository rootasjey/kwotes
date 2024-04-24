import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/about/feedback/feedback_chip_data.dart";
import "package:kwotes/screens/signin/signin_page_email_input.dart";
import "package:kwotes/types/enums/enum_feedback_communication_type.dart";
import "package:kwotes/types/enums/enum_feedback_type.dart";

class FeedbackContactBody extends StatelessWidget {
  const FeedbackContactBody({
    super.key,
    required this.emailController,
    required this.messageBodyController,
    this.communicationType = EnumFeedbackCommunicationType.none,
    this.feedbackType = EnumFeedbackType.bug,
    this.messageBodyFocusNode,
    this.onEmailChanged,
    this.onMessageBodyChanged,
    this.onTapOpenEmail,
    this.onTapSendFeedback,
    this.onFeedbackTypeChanged,
  });

  /// Feedback communication type.
  final EnumFeedbackCommunicationType communicationType;

  /// Feedback type.
  final EnumFeedbackType feedbackType;

  /// Message body focus node.
  final FocusNode? messageBodyFocusNode;

  /// Callback fired when user selects feedback type.
  final void Function(EnumFeedbackType feedbackType)? onFeedbackTypeChanged;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Callback fired when typed message body changed.
  final void Function(String messageBody)? onMessageBodyChanged;

  /// Callback fired when user taps on email button.
  final void Function()? onTapOpenEmail;

  /// Callback fired when user taps on send button.
  final void Function()? onTapSendFeedback;

  /// Input controller to follow, validate & submit email value.
  final TextEditingController emailController;

  /// Input controller to follow, validate & submit message value.
  final TextEditingController messageBodyController;

  @override
  Widget build(BuildContext context) {
    if (communicationType == EnumFeedbackCommunicationType.none) {
      return const SizedBox.shrink();
    }

    final Color accentColor = Constants.colors.lists;

    if (communicationType == EnumFeedbackCommunicationType.email) {
      return Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: ElevatedButton.icon(
          onPressed: onTapOpenEmail,
          icon: const Icon(TablerIcons.mail, size: 18.0),
          label: Text(
            "Send email".tr(),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: accentColor,
            textStyle: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: BorderSide(
                color: accentColor,
                width: 2.0,
              ),
            ),
          ),
        ),
      ).animate().fadeIn().slideY(
            begin: 0.4,
            end: 0.0,
            duration: 75.ms,
            curve: Curves.decelerate,
          );
    }

    if (communicationType == EnumFeedbackCommunicationType.form) {
      const double borderWidth = 2.0;
      final borderRadius = BorderRadius.circular(4.0);
      final Color? foregroundColor =
          Theme.of(context).textTheme.bodyMedium?.color;

      const MaterialColor bugColor = Colors.grey;
      const MaterialColor helpColor = Colors.grey;
      const MaterialColor wordColor = Colors.grey;

      final chipDataList = [
        FeedbackChipData(
          color: bugColor,
          label: "feedback.bug".tr(),
          type: EnumFeedbackType.bug,
        ),
        FeedbackChipData(
          color: helpColor,
          label: "feedback.help".tr(),
          type: EnumFeedbackType.help,
        ),
        FeedbackChipData(
          color: wordColor,
          label: "feedback.word".tr(),
          type: EnumFeedbackType.word,
        ),
      ];

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60.0,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: chipDataList.length,
              itemBuilder: (context, index) {
                final FeedbackChipData chipData = chipDataList[index];

                return ChoiceChip(
                  selected: feedbackType == chipData.type,
                  label: Text(chipData.label),
                  onSelected: (value) =>
                      onFeedbackTypeChanged?.call(chipData.type),
                  selectedColor: chipData.color.shade50,
                  shape: StadiumBorder(
                    side:
                        BorderSide(color: chipData.color.shade300, width: 1.2),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 8.0);
              },
            ),
          ),
          SigninPageEmailInput(
            emailController: emailController,
            accentColor: accentColor,
            labelText: "email.name_optional".tr(),
            hintText: "feedback.email_hint".tr(),
            margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            borderRadius: borderRadius,
            borderWidth: borderWidth,
            onEmailChanged: onEmailChanged,
          ),
          TextField(
            autofocus: false,
            focusNode: messageBodyFocusNode,
            onChanged: onMessageBodyChanged,
            controller: messageBodyController,
            minLines: 4,
            maxLines: null,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              isDense: true,
              labelText: "feedback.name".tr(),
              hintText: "feedback.hint".tr(),
              alignLabelWithHint: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ),
              border: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: accentColor,
                  width: borderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: foregroundColor?.withOpacity(0.4) ?? Colors.white12,
                  width: borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: accentColor,
                  width: borderWidth,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ElevatedButton.icon(
              onPressed: onTapSendFeedback,
              icon: const Icon(TablerIcons.send, size: 18.0),
              label: Text("email.send".tr()),
              style: ElevatedButton.styleFrom(
                foregroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                  side: BorderSide(
                    color: accentColor,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 36.0, bottom: 0.0),
            child: Divider(
              color: foregroundColor?.withOpacity(0.4),
            ),
          ),
        ].animate(interval: 25.ms).fadeIn().slideY(
              begin: 0.4,
              end: 0.0,
              duration: 75.ms,
              curve: Curves.decelerate,
            ),
      );
    }

    return const Placeholder();
  }
}
