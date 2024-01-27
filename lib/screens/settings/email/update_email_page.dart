import "dart:async";

import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/settings/email/update_email_page_body.dart";
import "package:kwotes/screens/settings/email/update_email_page_header.dart";
import "package:kwotes/types/action_return_value.dart";
import "package:kwotes/types/cloud_fun_error.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:loggy/loggy.dart";

class UpdateEmailPage extends StatefulWidget {
  /// Update email page.
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> with UiLoggy {
  /// True if the email entered is available.
  bool _isEmailAvailable = true;

  /// Random accent color.
  Color? _accentColor;

  /// Password focus node.
  final _passwordFocusNode = FocusNode();

  /// Email text controller.
  final TextEditingController _emailTextController = TextEditingController();

  /// Password text controller.
  final TextEditingController _passwordTextController = TextEditingController();

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Error message.
  String _errorMessage = "";

  /// Password error message.
  String _passwordErrorMessage = "";

  /// Debounce timer for email check.
  Timer? _emailCheckTimer;

  @override
  void initState() {
    super.initState();
    _accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: true,
    );
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _passwordFocusNode.dispose();
    _emailCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final EdgeInsets margin = isMobileSize
        ? const EdgeInsets.only(left: 24.0)
        : const EdgeInsets.only(left: 48.0);

    return BasicShortcuts(
      autofocus: false,
      onCancel: context.beamBack,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            UpdateEmailPageHeader(
              accentColor: _accentColor,
              isMobileSize: isMobileSize,
              onTapLeftPartHeader: onTapLeftPartHeader,
            ),
            UpdateEmailPageBody(
              margin: margin,
              isMobileSize: isMobileSize,
              emailController: _emailTextController,
              passwordFocusNode: _passwordFocusNode,
              pageState: _pageState,
              errorMessage: _errorMessage,
              onEmailChanged: onEmailChanged,
              onTapUpdateButton: tryUpdateEmail,
              passwordController: _passwordTextController,
              passwordErrorMessage: _passwordErrorMessage,
              onPasswordChanged: onPasswordChanged,
            ),
          ],
        ),
      ),
    );
  }

  /// Return true if the username entered is in correct format.
  bool isEmailInCorrectFormat(String text) {
    if (text.isEmpty) {
      _errorMessage = "input.error.empty".tr();
      return false;
    }

    if (text.length < 3) {
      _errorMessage = "input.error.minimum_length".tr(args: ["3"]);
      return false;
    }

    final bool isWellFormatted = UserActions.checkEmailFormat(text);

    if (!isWellFormatted) {
      _errorMessage = "input.error.email_not_valid".tr();
      return false;
    }

    return true;
  }

  /// Called when the email text field changes.
  /// Check for email availability.
  void onEmailChanged(String newEmail) async {
    final bool isOk = isEmailInCorrectFormat(newEmail);
    if (!isOk) {
      setState(() {});
      return;
    }

    setState(() {
      _pageState = EnumPageState.checkingUsername;
      _errorMessage = "";
    });

    _emailCheckTimer?.cancel();
    _emailCheckTimer = Timer(const Duration(seconds: 1), () async {
      _isEmailAvailable = await UserActions.checkEmailAvailability(newEmail);

      if (!_isEmailAvailable) {
        setState(() {
          _errorMessage = "input.error.username_not_available".tr();
          _pageState = EnumPageState.idle;
        });

        return;
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _errorMessage = "";
      });
    });
  }

  void onTapLeftPartHeader() {
    if (context.canBeamBack) {
      context.beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  void onPasswordChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordErrorMessage = "input.error.password_required".tr();
      });
    }
  }

  void tryUpdateEmail() async {
    if (!isEmailInCorrectFormat(_emailTextController.text)) {
      setState(() {});
      return;
    }

    setState(() {
      _errorMessage = "";
      _pageState = EnumPageState.loading;
    });

    try {
      _isEmailAvailable = await UserActions.checkEmailAvailability(
        _emailTextController.text,
      );

      if (!_isEmailAvailable) {
        setState(() {
          _pageState = EnumPageState.idle;
          _errorMessage = "input.error.username_not_available".tr();
        });

        // Snack.e(
        //   context: context,
        //   message: "The name $newUserName is not available",
        // );

        return;
      }

      final ActionReturnValue emailUpdateResp = await Utils.state.updateEmail(
        password: _passwordTextController.text,
        newEmail: _emailTextController.text,
      );

      if (!emailUpdateResp.success) {
        final CloudFunError? exception =
            emailUpdateResp.error as CloudFunError?;

        setState(() {
          _pageState = EnumPageState.idle;
        });

        loggy.error(exception?.message);

        // Snack.e(
        //   context: context,
        //   message: "[code: ${exception.code}] - ${exception.message}",
        // );

        return;
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _emailTextController.clear();
      });

      // stateUser.setUsername(currentUsername);
      // Snack.s(
      //   context: context,
      //   message: "Your username has been successfully updated.",
      // );

      if (!mounted) {
        return;
      }

      context.beamBack();
    } catch (error) {
      loggy.error(error);

      setState(() {
        _pageState = EnumPageState.idle;
      });

      // Snack.e(
      //   context: context,
      //   message: "Sorry, there was an error. "
      //       "Can you try again later or contact us if the issue persists?",
      // );
    }
  }
}
