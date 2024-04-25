import "dart:async";

import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/screens/settings/username/update_username_page_body.dart";
import "package:kwotes/types/cloud_fun_error.dart";
import "package:kwotes/types/cloud_fun_response.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";

/// Update username page.
class UpdateUsernamePage extends StatefulWidget {
  const UpdateUsernamePage({super.key});

  @override
  State<UpdateUsernamePage> createState() => _UpdateUsernamePageState();
}

class _UpdateUsernamePageState extends State<UpdateUsernamePage> with UiLoggy {
  /// True if the username entered is available.
  bool _isNameAvailable = true;

  /// Password focus node.
  final FocusNode _passwordFocusNode = FocusNode();

  /// Username text controller.
  final TextEditingController _usernameTextController = TextEditingController();

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
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final UserFirestore userFirestore =
        context.observe<UserFirestore>(EnumSignalId.userFirestore);

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onTapBackButton: context.beamBack,
              title: "username.edit.name".tr(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: isMobileSize
                    ? const EdgeInsets.only(top: 8.0, left: 28.0, right: 28.0)
                    : EdgeInsets.zero,
                child: FractionallySizedBox(
                  widthFactor: isMobileSize ? 1.0 : 0.4,
                  child: Text(
                    "username.update.tips".tr(),
                    textAlign: isMobileSize ? TextAlign.left : TextAlign.center,
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 14.0,
                        color: foregroundColor?.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            UpdateUsernamePageBody(
              isMobileSize: isMobileSize,
              usernameController: _usernameTextController,
              passwordFocusNode: _passwordFocusNode,
              pageState: _pageState,
              errorMessage: _errorMessage,
              onUsernameChanged: onUsernameChanged,
              onTapUpdateButton: tryUpdateUsername,
              username: userFirestore.name,
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

    setState(() => _pageState = EnumPageState.updatingUsername);
    final String username = _usernameTextController.text;

    try {
      _isNameAvailable = await UserActions.checkUsernameAvailability(
        username,
      );

      if (!_isNameAvailable) {
        setState(() {
          _pageState = EnumPageState.idle;
          _errorMessage =
              "${"input.error.username_not_available".tr()} : $username";
        });

        if (!mounted) return;

        Utils.graphic.showSnackbar(
          context,
          duration: const Duration(seconds: 8),
          message: _errorMessage,
        );
        return;
      }

      final CloudFunResponse usernameUpdateResp =
          await Utils.state.updateUsername(
        username,
      );

      if (!usernameUpdateResp.success) {
        final CloudFunError? exception = usernameUpdateResp.error;
        loggy.error(exception?.message);
        setState(() => _pageState = EnumPageState.idle);

        if (!mounted) return;
        Utils.graphic.showSnackbar(
          context,
          duration: const Duration(seconds: 8),
          message: "${exception?.code} - ${exception?.message}",
        );
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

      if (!mounted) return;
      context.beamBack();
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);

      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        duration: const Duration(seconds: 8),
        message: error.toString(),
      );
    }
  }
}
