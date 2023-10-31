import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/settings/delete_account/delete_account_page_body.dart";
import "package:kwotes/screens/settings/delete_account/delete_account_page_header.dart";
import "package:kwotes/types/action_return_value.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:loggy/loggy.dart";
import "package:timer_snackbar/timer_snackbar.dart";

/// Delete account page.
class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> with UiLoggy {
  /// Password controller.
  final _passwordTextController = TextEditingController();

  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Error message.
  String _errorMessage = "";

  @override
  void dispose() {
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Color randomColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );

    return BasicShortcuts(
      autofocus: false,
      onCancel: context.beamBack,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            ApplicationBar(
              isMobileSize: isMobileSize,
            ),
            DeleteAccountPageHeader(
              isMobileSize: isMobileSize,
              onTapLeftPartHeader: onTapLeftPartHeader,
              randomColor: randomColor,
            ),
            DeleteAccountPageBody(
              errorMessage: _errorMessage,
              isMobileSize: isMobileSize,
              passwordController: _passwordTextController,
              pageState: _pageState,
              onTapUpdateButton: tryDeleteAccount,
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

  void onTapLeftPartHeader() {
    if (context.canBeamBack) {
      context.beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  void tryDeleteAccount() async {
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
        setState(() {
          _pageState = EnumPageState.idle;
        });

        if (!mounted) {
          return;
        }

        timerSnackbar(
          context: context,
          contentText: deleteAccountResp.error.toString(),
          afterTimeExecute: () {},
        );

        return;
      }

      setState(() {
        _pageState = EnumPageState.idle;
        _passwordTextController.clear();
      });

      if (!mounted) {
        return;
      }

      timerSnackbar(
        context: context,
        contentText: "account.delete.success".tr(),
        afterTimeExecute: () {},
      );

      Utils.state.logout();
      context.beamBack();
    } catch (error) {
      loggy.error(error);

      setState(() {
        _pageState = EnumPageState.idle;
      });

      timerSnackbar(
        context: context,
        contentText: "account.delete.error".tr(),
        afterTimeExecute: () {},
      );
    }
  }
}
