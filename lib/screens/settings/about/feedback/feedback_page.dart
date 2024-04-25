import "package:beamer/beamer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/settings/about/big_text_header.dart";
import "package:kwotes/screens/settings/about/feedback/feeedback_page_body.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/types/enums/enum_feedback_communication_type.dart";
import "package:kwotes/types/enums/enum_feedback_type.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wave_divider/wave_divider.dart";

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with UiLoggy {
  /// Accent color
  Color _accentColor = Colors.amber;

  /// Feedback type.
  EnumFeedbackType _feedbackType = EnumFeedbackType.bug;

  /// Feedback communication type.
  EnumFeedbackCommunicationType _feedbackCommunicationType =
      EnumFeedbackCommunicationType.none;

  /// Page's current state (e.g. loading, idle, etc).
  EnumPageState _pageState = EnumPageState.idle;

  /// Input controller to follow, validate & submit user name/email value.
  final TextEditingController _emailController = TextEditingController();

  /// Input controller to follow, validate & submit message value.
  final TextEditingController _messageBodyController = TextEditingController();

  /// Used to focus email input (e.g. after error).
  final FocusNode _emailFocusNode = FocusNode();

  /// Used to focus message body input (e.g. after error).
  final FocusNode _messageBodyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: true,
    );

    _emailController.text = NavigationStateHelper.userEmailInput;
    _messageBodyController.text = NavigationStateHelper.feedbackMessageBody;
  }

  @override
  void dispose() {
    _messageBodyController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    _messageBodyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final String titleValue = "contact.us".tr();

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onTapBackButton: context.beamBack,
              title: titleValue,
              show: isMobileSize,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  BigTextHeader(
                    show: !isMobileSize,
                    accentColor: _accentColor,
                    titleValue: titleValue,
                  ),
                  WaveDivider(
                    padding: EdgeInsets.symmetric(
                      vertical: isMobileSize ? 24.0 : 48.0,
                    ),
                  ),
                ],
              ),
            ),
            FeedbackPageBody(
              accentColor: _accentColor,
              communicationType: _feedbackCommunicationType,
              feedbackType: _feedbackType,
              pageState: _pageState,
              isMobileSize: isMobileSize,
              emailController: _emailController,
              messageBodyController: _messageBodyController,
              onGoBack: onGoBack,
              onFeedbackTypeChanged: onFeedbackTypeChanged,
              onEmailChanged: onEmailChanged,
              onMessageBodyChanged: onMessageBodyChanged,
              onToggleEmail: onToggleEmail,
              onToggleForm: onToggleForm,
              onTapOpenEmail: onTapOpenEmail,
              onTapSendFeedback: onTapSendFeedback,
              // onEmailChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  void onEmailChanged(String email) {
    NavigationStateHelper.userEmailInput = email;
  }

  void onFeedbackTypeChanged(EnumFeedbackType feedbackType) {
    setState(() {
      _feedbackType = feedbackType;
    });
  }

  void onGoBack() {
    context.beamBack();
  }

  void onMessageBodyChanged(String messageBody) {
    NavigationStateHelper.feedbackMessageBody = messageBody;
  }

  /// Callback fired when user taps on send button.
  void onTapSendFeedback() async {
    setState(() => _pageState = EnumPageState.loading);

    try {
      final Signal<UserFirestore> signalUserFirestore = context.get(
        EnumSignalId.userFirestore,
      );

      await FirebaseFirestore.instance.collection("feedbacks").add({
        "email": _emailController.text,
        "message": _messageBodyController.text,
        "created_at": FieldValue.serverTimestamp(),
        "type": _feedbackType.name,
        "updated_at": FieldValue.serverTimestamp(),
        "communication_type": _feedbackCommunicationType.name,
        "user_id": signalUserFirestore.value.id,
      });

      NavigationStateHelper.feedbackMessageBody = "";
      NavigationStateHelper.userEmailInput = "";

      setState(() => _pageState = EnumPageState.done);
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Callback fired when user taps on email button.
  void onToggleEmail() {
    setState(() {
      _feedbackCommunicationType =
          _feedbackCommunicationType == EnumFeedbackCommunicationType.email
              ? EnumFeedbackCommunicationType.none
              : EnumFeedbackCommunicationType.email;
    });
  }

  /// Callback fired when user taps on form button.
  void onToggleForm() {
    setState(() {
      _feedbackCommunicationType =
          _feedbackCommunicationType == EnumFeedbackCommunicationType.form
              ? EnumFeedbackCommunicationType.none
              : EnumFeedbackCommunicationType.form;
    });
  }

  /// Callback fired when user taps on open email button.
  void onTapOpenEmail() {
    launchUrl(Uri.parse("mailto:${Constants.supportEmail}"));
  }
}
