import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/about/feedback/feedback_card.dart";
import "package:kwotes/screens/settings/about/feedback/feedback_complete_view.dart";
import "package:kwotes/screens/settings/about/feedback/feedback_contact_body.dart";
import "package:kwotes/types/enums/enum_feedback_communication_type.dart";
import "package:kwotes/types/enums/enum_feedback_type.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class FeedbackPageBody extends StatelessWidget {
  const FeedbackPageBody({
    super.key,
    required this.emailController,
    required this.messageBodyController,
    this.isMobileSize = false,
    this.accentColor = Colors.amber,
    this.pageState = EnumPageState.idle,
    this.communicationType = EnumFeedbackCommunicationType.none,
    this.onEmailChanged,
    this.onMessageBodyChanged,
    this.onGoBack,
    this.onToggleEmail,
    this.onToggleForm,
    this.onTapOpenEmail,
    this.feedbackType = EnumFeedbackType.bug,
    this.onTapSendFeedback,
    this.onFeedbackTypeChanged,
  });

  /// Adapt the body to the screen size.
  final bool isMobileSize;

  /// Accent color.
  final Color accentColor;

  /// Page's current state (e.g. loading, idle, etc).
  final EnumPageState pageState;

  /// Feedback communication type.
  final EnumFeedbackCommunicationType communicationType;

  /// Feedback type.
  final EnumFeedbackType feedbackType;

  /// Callback fired when user selects feedback type.
  final void Function(EnumFeedbackType feedbackType)? onFeedbackTypeChanged;

  /// Callback fired when user taps to go back.
  final void Function()? onGoBack;

  /// Callback fired when user taps to show/hide email button.
  final void Function()? onToggleEmail;

  /// Callback fired when user taps on form button.
  final void Function()? onToggleForm;

  /// Callback fired when user taps on open email button.
  final void Function()? onTapOpenEmail;

  /// Callback fired when user taps on send button.
  final void Function()? onTapSendFeedback;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Callback fired when typed message body changed.
  final void Function(String messageBody)? onMessageBodyChanged;

  /// Input controller to follow, validate & submit user name/email value.
  final TextEditingController emailController;

  /// Input controller to follow, validate & submit message value.
  final TextEditingController messageBodyController;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final EdgeInsets padding = isMobileSize
        ? const EdgeInsets.only(
            top: 0.0,
            left: 24.0,
            right: 24.0,
            bottom: 200.0,
          )
        : const EdgeInsets.symmetric(
            horizontal: 48.0,
            vertical: 48.0,
          );

    if (pageState == EnumPageState.done) {
      return FeedbackCompleteView(
        accentColor: accentColor,
        onGoBack: onGoBack,
        margin: padding,
      );
    }

    if (pageState == EnumPageState.loading) {
      return SliverPadding(
        padding: padding,
        sliver: LoadingView(
          message: "loading".tr(),
          useSliver: true,
        ),
      );
    }

    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: FractionallySizedBox(
          widthFactor: isMobileSize ? 0.9 : 0.80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: "feedback.description".tr(),
                  children: const [],
                ),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: isMobileSize ? 14.0 : 24.0,
                    fontWeight: FontWeight.w400,
                    color: foregroundColor?.withOpacity(0.6),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    FeedbackCard(
                      accentColor: accentColor,
                      titleValue: "form.name".tr(),
                      onTap: onToggleForm,
                      isMobileSize: isMobileSize,
                      selected: communicationType ==
                          EnumFeedbackCommunicationType.form,
                    ),
                    FeedbackCard(
                      accentColor: Constants.colors.authors,
                      titleValue: "email.name".tr(),
                      onTap: onToggleEmail,
                      isMobileSize: isMobileSize,
                      selected: communicationType ==
                          EnumFeedbackCommunicationType.email,
                    ),
                  ],
                ),
              ),
              FeedbackContactBody(
                emailController: emailController,
                messageBodyController: messageBodyController,
                communicationType: communicationType,
                onTapOpenEmail: onTapOpenEmail,
                feedbackType: feedbackType,
                onFeedbackTypeChanged: onFeedbackTypeChanged,
                onTapSendFeedback: onTapSendFeedback,
                onEmailChanged: onEmailChanged,
                onMessageBodyChanged: onMessageBodyChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
