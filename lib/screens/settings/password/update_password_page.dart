import "dart:async";

import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/settings/password/update_password_page_body.dart";
import "package:kwotes/screens/settings/password/update_password_page_header.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/types/action_return_value.dart";
import "package:kwotes/types/cloud_fun_error.dart";
import "package:kwotes/types/credentials.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/password_checks.dart";
import "package:loggy/loggy.dart";
import "package:verbal_expressions/verbal_expressions.dart";

/// Update user's password page.
class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> with UiLoggy {
  /// Password focus node.
  final FocusNode _newPasswordFocusNode = FocusNode();

  /// Current password controller.
  final TextEditingController _currentPasswordController =
      TextEditingController();

  /// New password controller.
  final TextEditingController _newPasswordController = TextEditingController();

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Performs password checks and save the results.
  PasswordChecks _passwordChecks = PasswordChecks.empty();

  /// Current password error message.
  String _currentPasswordErrorMessage = "";

  /// New password error message.
  String _newPasswordErrorMessage = "";

  /// Timer to debounce username check.
  Timer? _newPasswordCheckTimer;

  final VerbalExpression _vbeDigit = VerbalExpression()
    ..digit()
    ..atLeast(1);

  final VerbalExpression _vbeLowerCase = VerbalExpression()
    ..range([Range("a", "z")]);

  final VerbalExpression _vbeUpperCase = VerbalExpression()
    ..range([Range("A", "Z")]);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _newPasswordCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Color accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: true,
    );

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onTapBackButton: context.beamBack,
              title: "password.edit.name".tr(),
            ),
            UpdatePasswordPageHeader(
              accentColor: accentColor,
              isMobileSize: isMobileSize,
              onTapLeftPartHeader: onTapLeftPartHeader,
              onTapRemindMe: onTapRemindMe,
              passwordChecks: _passwordChecks,
            ),
            UpdatePasswordPageBody(
              currentPasswordController: _currentPasswordController,
              isMobileSize: isMobileSize,
              newPasswordController: _newPasswordController,
              newPasswordFocusNode: _newPasswordFocusNode,
              pageState: _pageState,
              currentPasswordErrorMessage: _currentPasswordErrorMessage,
              newPasswordErrorMessage: _newPasswordErrorMessage,
              onCurrentPasswordChanged: onCurrentPasswordChanged,
              onNewPasswordChanged: onNewPasswordChanged,
              onTapUpdateButton: tryUpdatePassword,
            ),
          ],
        ),
      ),
    );
  }

  /// Return true if the password entered is in correct format.
  bool isNewPasswordInCorrectFormat(String text) {
    bool isOk = true;
    _newPasswordErrorMessage = "";

    if (text.isEmpty) {
      setState(() {
        _newPasswordErrorMessage = "password.error.new_empty".tr();
        _passwordChecks = PasswordChecks.empty();
      });
      isOk = false;
      return isOk;
    }

    if (_vbeDigit.toRegExp().hasMatch(text)) {
      _passwordChecks = _passwordChecks.copyWith(hasDigit: true);
    } else {
      _passwordChecks = _passwordChecks.copyWith(hasDigit: false);
      isOk = false;
    }

    if (_vbeLowerCase.toRegExp().hasMatch(text)) {
      _passwordChecks = _passwordChecks.copyWith(hasLowercase: true);
    } else {
      _passwordChecks = _passwordChecks.copyWith(hasLowercase: false);
      isOk = false;
    }

    if (_vbeUpperCase.toRegExp().hasMatch(text)) {
      _passwordChecks = _passwordChecks.copyWith(hasUppercase: true);
    } else {
      _passwordChecks = _passwordChecks.copyWith(hasUppercase: false);
      isOk = false;
    }

    if (text.length < 7) {
      setState(() {
        _newPasswordErrorMessage = "password.error.minimum_length".tr(
          args: ["6"],
        );
        _passwordChecks = _passwordChecks.copyWith(hasMinimumLength: false);
      });
      isOk = false;
      return isOk;
    }

    setState(() {
      _newPasswordErrorMessage = "";
      _passwordChecks = _passwordChecks.copyWith(hasMinimumLength: true);
    });

    return isOk;
  }

  void onTapLeftPartHeader() {
    if (context.canBeamBack) {
      context.beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  /// Called when the current password field changes.
  void onCurrentPasswordChanged(String currentPassword) async {
    if (currentPassword.isEmpty) {
      setState(() {
        _currentPasswordErrorMessage = "password.error.current_empty".tr();
      });
      return;
    }

    if (currentPassword.length < 6) {
      setState(() {
        _currentPasswordErrorMessage =
            "password.error.minimum_length".tr(args: ["6"]);
      });
      return;
    }

    setState(() {
      _currentPasswordErrorMessage = "";
    });
  }

  /// Called when the new password field changes.
  void onNewPasswordChanged(String value) {
    isNewPasswordInCorrectFormat(value);
  }

  /// Try to update user password.
  void tryUpdatePassword() async {
    if (!isNewPasswordInCorrectFormat(_currentPasswordController.text)) {
      setState(() {});
      return;
    }

    setState(() {
      _newPasswordErrorMessage = "";
    });

    try {
      final ActionReturnValue usernameUpdateResp =
          await Utils.state.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!usernameUpdateResp.success) {
        setState(() {
          _pageState = EnumPageState.idle;
        });

        final CloudFunError? exception =
            usernameUpdateResp.error as CloudFunError?;

        loggy.error(exception?.message);

        if (!mounted) {
          return;
        }

        Utils.graphic.showSnackbar(
          context,
          message: "[code: ${exception?.code}] • ${exception?.message}",
        );

        return;
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _currentPasswordController.clear();
      });

      if (!mounted) {
        return;
      }

      Utils.graphic.showSnackbar(
        context,
        message: "password.update.success".tr(),
      );

      context.beamBack();
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);
      Utils.graphic.showSnackbar(
        context,
        message: "password.update.error".tr(),
      );
    }
  }

  /// Remin the user their password.
  void onTapRemindMe() async {
    final Credentials credentials = await Utils.vault.getCredentials();

    if (!mounted) return;
    Utils.graphic.showSnackbar(
      context,
      message: credentials.password,
    );
  }
}
