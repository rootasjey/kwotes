import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/forgot_password_location.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/screens/signin/signin_page_body.dart";
import "package:kwotes/screens/signin/signin_page_header.dart";
import "package:kwotes/types/enums/enum_app_bar_mode.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/user/user_auth.dart";
import "package:loggy/loggy.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/signup_location.dart";

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> with UiLoggy {
  /// Page's current state (e.g. loading, idle, etc).
  EnumPageState _pageState = EnumPageState.idle;

  /// Input controller to follow, validate & submit user name/email value.
  final TextEditingController _emailController = TextEditingController();

  /// Input controller to follow, validate & submit user password value.
  final TextEditingController _passwordController = TextEditingController();

  /// Used to focus email input (e.g. after error).
  final FocusNode _emailFocusNode = FocusNode();

  /// Used to focus password input (e.g. after error).
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "signin".tr(),
      );
    }

    final Color randomColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(
            mode: EnumAppBarMode.signin,
            isMobileSize: isMobileSize,
            title: const SizedBox.shrink(),
            rightChildren: [
              CircleButton(
                onTap: goToSettings,
                backgroundColor: Colors.transparent,
                icon: const Icon(TablerIcons.settings),
              ),
            ],
          ),
          SigninPageHeader(
            isMobileSize: isMobileSize,
            onNavigateToCreateAccount: goToSignupPage,
            randomColor: randomColor,
            margin: const EdgeInsets.only(top: 42.0),
          ),
          SigninPageBody(
            isDark: isDark,
            isMobileSize: isMobileSize,
            emailFocusNode: _emailFocusNode,
            passwordFocusNode: _passwordFocusNode,
            emailController: _emailController,
            passwordController: _passwordController,
            onNavigateToForgotPassword: goToForgotPasswordPage,
            onNavigateToCreateAccount: goToSignupPage,
            onCancel: onCancel,
            onSubmit: (String name, String password) => trySignin(
              name: name,
              password: password,
            ),
            randomColor: randomColor,
          ),
        ],
      ),
    );
  }

  /// Attempt to sign in.
  void trySignin({required String name, required String password}) async {
    if (!inputValuesOk(name: name, password: password)) {
      return;
    }

    setState(() => _pageState = EnumPageState.loading);

    try {
      final UserAuth? userCredential = await Utils.state.signIn(
        email: name,
        password: password,
      );

      if (userCredential == null) {
        loggy.error("account.error.does_not_exist".tr());
        if (!mounted) return;
        Utils.graphic.showSnackbar(
          context,
          message: "account.error.does_not_exist".tr(),
        );
        return;
      }

      if (!mounted) return;
      Beamer.of(context).beamToReplacementNamed(DashboardContentLocation.route);
    } catch (error) {
      loggy.error("password.error.incorrect".tr());
      Utils.graphic.showSnackbar(
        context,
        message: "password.error.incorrect".tr(),
      );
    } finally {
      setState(() => _pageState = EnumPageState.idle);
    }
  }

  /// Navigate to the forgot password page.
  void goToForgotPasswordPage() {
    final BeamerDelegate beamer = Beamer.of(context);
    final BeamState beamState = beamer.currentBeamLocation.state as BeamState;
    final List<String> pathSegments = beamState.pathPatternSegments;
    final String prefix = pathSegments.first;

    if (prefix == "d") {
      beamer.beamToNamed(DashboardContentLocation.forgotPasswordRoute);
      return;
    }

    beamer.root.beamToNamed(ForgotPasswordLocation.route);
  }

  /// Navigate to the create account page.
  void goToSignupPage() {
    final BeamerDelegate beamer = Beamer.of(context);
    final BeamState beamState = beamer.currentBeamLocation.state as BeamState;
    final List<String> pathSegments = beamState.pathPatternSegments;
    final String prefix = pathSegments.first;

    if (prefix == "d") {
      beamer.beamToNamed(DashboardContentLocation.signupRoute);
      return;
    }

    beamer.root.beamToNamed(SignupLocation.route);
  }

  /// Return true if all inputs (email, password) are in the correct format.
  bool inputValuesOk({required String name, required String password}) {
    if (!UserActions.checkEmailFormat(name)) {
      loggy.error("email.error.empty".tr());
      Utils.graphic.showSnackbar(
        context,
        message: "email.error.empty".tr(),
      );

      _emailFocusNode.requestFocus();
      return false;
    }

    if (password.isEmpty) {
      loggy.error("password.error.empty_forbidden".tr());
      Utils.graphic.showSnackbar(
        context,
        message: "password.error.empty_forbidden".tr(),
      );

      _passwordFocusNode.requestFocus();
      return false;
    }

    return true;
  }

  /// Navigate to the previous page.
  void onCancel() {
    if (Beamer.of(context).beamingHistory.isNotEmpty) {
      Beamer.of(context).beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  /// Navigate to the settings page.
  void goToSettings() {
    final BeamerDelegate beamer = Beamer.of(context);
    final BeamState beamState = beamer.currentBeamLocation.state as BeamState;
    final List<String> pathSegments = beamState.pathPatternSegments;
    final String prefix = pathSegments.first;

    if (prefix == "d") {
      beamer.beamToNamed(DashboardContentLocation.settingsRoute);
      return;
    }

    Beamer.of(context, root: true).beamToNamed(SettingsLocation.route);
  }
}
