import "dart:async";

import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/settings/username/username_page_body.dart";
import "package:kwotes/screens/settings/username/username_page_header.dart";
import "package:kwotes/types/cloud_fun_error.dart";
import "package:kwotes/types/cloud_fun_response.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:loggy/loggy.dart";

/// Update username page.
class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> with UiLoggy {
  /// True if the username entered is available.
  bool _isNameAvailable = true;

  /// Password focus node.
  final _passwordFocusNode = FocusNode();

  /// Username text controller.
  final _usernameTextController = TextEditingController();

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Error message.
  String _errorMessage = "";

  /// Timer to debounce username check.
  Timer? _usernameCheckTimer;

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordFocusNode.dispose();
    _usernameCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return BasicShortcuts(
      autofocus: false,
      onCancel: context.beamBack,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            ApplicationBar(
              isMobileSize: isMobileSize,
            ),
            UsernamePageHeader(
              isMobileSize: isMobileSize,
              onTapLeftPartHeader: onTapLeftPartHeader,
            ),
            UsernamePageBody(
              isMobileSize: isMobileSize,
              usernameController: _usernameTextController,
              passwordFocusNode: _passwordFocusNode,
              pageState: _pageState,
              errorMessage: _errorMessage,
              onUsernameChanged: onUsernameChanged,
              onTapUpdateButton: tryUpdateUsername,
            ),
          ],
        ),
      ),
    );
  }

  /// Return true if the username entered is in correct format.
  bool isUsernameInCorrectFormat(String text) {
    if (text.isEmpty) {
      _errorMessage = "input.error.empty".tr();
      return false;
    }

    if (text.length < 3) {
      _errorMessage = "input.error.minimum_length".tr(args: ["3"]);
      return false;
    }

    final bool isWellFormatted = UserActions.checkUsernameFormat(text);

    if (!isWellFormatted) {
      _errorMessage = "input.error.alphanumerical".tr();
      return false;
    }

    return true;
  }

  void onTapLeftPartHeader() {
    if (context.canBeamBack) {
      context.beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  /// Called when the username text field changes.
  /// Check for username availability.
  void onUsernameChanged(String newUsername) async {
    final bool isOk = isUsernameInCorrectFormat(newUsername);
    if (!isOk) {
      setState(() {});
      return;
    }

    setState(() {
      _pageState = EnumPageState.checkingUsername;
      _errorMessage = "";
    });

    _usernameCheckTimer?.cancel();
    _usernameCheckTimer = Timer(const Duration(seconds: 1), () async {
      _isNameAvailable =
          await UserActions.checkUsernameAvailability(newUsername);

      if (!_isNameAvailable) {
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

  void tryUpdateUsername() async {
    if (!isUsernameInCorrectFormat(_usernameTextController.text)) {
      setState(() {});
      return;
    }

    setState(() {
      _errorMessage = "";
      _pageState = EnumPageState.loading;
    });

    try {
      _isNameAvailable = await UserActions.checkUsernameAvailability(
        _usernameTextController.text,
      );

      if (!_isNameAvailable) {
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

      final CloudFunResponse usernameUpdateResp =
          await Utils.state.updateUsername(
        _usernameTextController.text,
      );

      if (!usernameUpdateResp.success) {
        final CloudFunError? exception = usernameUpdateResp.error;

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
        _usernameTextController.clear();
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
