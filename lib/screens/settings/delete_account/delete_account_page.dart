import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/settings/delete_account/delete_account_page_body.dart";
import "package:kwotes/screens/settings/delete_account/delete_account_page_header.dart";
import "package:kwotes/types/action_return_value.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:loggy/loggy.dart";

/// Delete account page.
class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> with UiLoggy {
  /// Hide password input text if true.
  bool _hidePassword = true;

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Error message.
  String _errorMessage = "";

  /// Password controller.
  final TextEditingController _passwordTextController = TextEditingController();
  @override
  void dispose() {
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Color accentColor = Constants.colors.delete;

    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "${"account.delete.ing".tr()}...",
      );
    }

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            DeleteAccountPageHeader(
              isMobileSize: isMobileSize,
              onTapLeftPartHeader: onTapLeftPartHeader,
              accentColor: accentColor,
              margin: const EdgeInsets.only(top: 16.0),
            ),
            DeleteAccountPageBody(
              errorMessage: _errorMessage,
              hidePassword: _hidePassword,
              isMobileSize: isMobileSize,
              margin: const EdgeInsets.only(top: 16.0),
              passwordController: _passwordTextController,
              pageState: _pageState,
              onHidePasswordChanged: onHidePasswordChanged,
              onValidateDeletion: deleteAccount,
            ),
          ],
        ),
      ),
    );
  }

  /// Return true if the username entered is in correct format.
  bool isPasswordInCorrectFormat(String text) {
    if (text.isEmpty) {
      _errorMessage = "input.error.empty".tr();
      return false;
    }

    return true;
  }

  /// Callback fired when left part header is tapped.
  /// If the user can beam back, do so.
  void onTapLeftPartHeader() {
    if (context.canBeamBack) {
      context.beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  /// Delete account.
  void deleteAccount() async {
    if (!isPasswordInCorrectFormat(_passwordTextController.text)) {
      Utils.graphic.showSnackbar(context, message: _errorMessage);
      setState(() {});
      return;
    }

    setState(() {
      _errorMessage = "";
      _pageState = EnumPageState.loading;
    });

    try {
      final ActionReturnValue deleteAccountResp = await Utils.state
          .deleteAccount(password: _passwordTextController.text);

      if (!deleteAccountResp.success) {
        loggy.error(deleteAccountResp.error);
        setState(() => _pageState = EnumPageState.idle);
        if (!mounted) return;

        Utils.graphic.showSnackbar(
          context,
          message: deleteAccountResp.error.toString(),
        );

        return;
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _passwordTextController.clear();
      });

      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: "account.delete.success".tr(),
      );

      context.beamToNamed(DashboardContentLocation.signinRoute);
    } catch (error) {
      loggy.error(error);
      setState(() => _pageState = EnumPageState.idle);
      Utils.graphic.showSnackbar(
        context,
        message: "account.delete.error".tr(),
      );
    }
  }

  /// Callback to hide/show password.
  void onHidePasswordChanged(bool value) {
    setState(() => _hidePassword = value);
  }
}
