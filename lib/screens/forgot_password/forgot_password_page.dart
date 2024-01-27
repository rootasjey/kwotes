import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page_header.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:loggy/loggy.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page_body.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page_completed.dart";

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with UiLoggy {
  /// Page's state (e.g. idle, loading, error).
  /// If state is `done`, the operation is completed (e.g. email has been sent).
  EnumPageState _pageState = EnumPageState.idle;

  /// Error message to display next to the email input.
  /// If this is empty, there's no error for this specific input.
  String _emailErrorMessage = "";

  /// Input controller to follow, validate & submit user email value.
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = NavigationStateHelper.userEmailInput;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    final double windowWidth = windowSize.width;

    if (_pageState == EnumPageState.done) {
      return ForgotPasswordPageCompleted(
        windowWidth: windowWidth,
      );
    }

    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "email.sending_password_recovery".tr(),
      );
    }

    final double mobileTreshold = Utils.measurements.mobileWidthTreshold;
    final bool isMobileSize =
        windowWidth <= mobileTreshold || windowSize.height <= mobileTreshold;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color randomColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: true,
    );

    return Scaffold(
      body: CustomScrollView(slivers: [
        ApplicationBar(
          title: const SizedBox.shrink(),
          isMobileSize: isMobileSize,
        ),
        ForgotPasswordPageHeader(
          isMobileSize: isMobileSize,
          margin: const EdgeInsets.only(top: 42.0, left: 12.0, right: 12.0),
          randomColor: randomColor,
        ),
        ForgotPasswordPageBody(
          isDark: isDark,
          isMobileSize: isMobileSize,
          emailController: _emailController,
          emailErrorMessage: _emailErrorMessage,
          onCancel: onCancel,
          onEmailChanged: checkEmail,
          onSubmit: trySendResetLink,
          randomColor: randomColor,
        ),
      ]),
    );
  }

  /// Check for input validity: emptyness, format, availability.
  /// Poppulate email error message if there's an error in one of those steps.
  bool checkEmail(String email) {
    email = email.trim();

    if (email.isEmpty) {
      setState(() => _emailErrorMessage = "email.error.empty".tr());
      Utils.graphic.showSnackbar(context, message: "email.error.empty".tr());
      return false;
    }

    final bool isWellFormatted = UserActions.checkEmailFormat(email);

    if (!isWellFormatted) {
      setState(() => _emailErrorMessage = "email.error.not_valid".tr());
      Utils.graphic.showSnackbar(
        context,
        message: "email.error.not_valid".tr(),
      );
      return false;
    }

    return true;
  }

  /// Navigate back to previous or home page.
  void onCancel() {
    if (Beamer.of(context).beamingHistory.isNotEmpty) {
      Beamer.of(context).beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  void trySendResetLink(String email) async {
    if (!checkEmail(email)) {
      return;
    }

    try {
      setState(() {
        _pageState = EnumPageState.loading;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        _pageState = EnumPageState.done;
      });
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() => _pageState = EnumPageState.idle);
      Utils.graphic.showSnackbar(context, message: "email.doesnt_exist".tr());
    }
  }
}
