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
import "package:kwotes/router/navigation_state_helper.dart";
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
  /// Used to hide/show password.
  bool _hidePassword = true;

  Color _accentColor = Colors.amber;

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
  void initState() {
    super.initState();

    _accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: true,
    );

    _emailController.text = NavigationStateHelper.userEmailInput;
    _passwordController.text = NavigationStateHelper.userPasswordInput;
  }

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
        message: "signin.in".tr(),
      );
    }

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
                onTap: navigateToSettings,
                backgroundColor: Colors.transparent,
                icon: const Icon(TablerIcons.settings),
              ),
            ],
          ),
          SigninPageHeader(
            isMobileSize: isMobileSize,
            onNavigateToCreateAccount: navigateToSignupPage,
            accentColor: _accentColor,
            margin: const EdgeInsets.only(top: 42.0),
          ),
          SigninPageBody(
            accentColor: _accentColor,
            isDark: isDark,
            emailFocusNode: _emailFocusNode,
            emailController: _emailController,
            hidePassword: _hidePassword,
            isMobileSize: isMobileSize,
            passwordController: _passwordController,
            onEmailChanged: onEmailChanged,
            onHidePasswordChanged: onHidePasswordChanged,
            onPasswordChanged: onPasswordChanged,
            onNavigateToForgotPassword: navigateToForgotPasswordPage,
            onNavigateToCreateAccount: navigateToSignupPage,
            onCancel: onCancel,
            onSubmit: (String name, String password) => connectToAccount(
              name: name,
              password: password,
            ),
            passwordFocusNode: _passwordFocusNode,
          ),
        ],
      ),
    );
  }

  /// Attempt to sign in user.
  void connectToAccount(
      {required String name, required String password}) async {
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

  /// Return true if all inputs (email, password) are in the correct format.
  bool inputValuesOk({required String name, required String password}) {
    if (name.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "email.error.empty_forbidden".tr(),
      );

      _emailFocusNode.requestFocus();
      return false;
    }

    if (password.isEmpty) {
      Utils.graphic.showSnackbar(
        context,
        message: "password.error.empty_forbidden".tr(),
      );

      _passwordFocusNode.requestFocus();
      return false;
    }

    if (!UserActions.checkEmailFormat(name)) {
      Utils.graphic.showSnackbar(
        context,
        message: "email.error.not_valid".tr(),
      );

      _emailFocusNode.requestFocus();
      return false;
    }

    return true;
  }

  /// Navigate to the forgot password page.
  void navigateToForgotPasswordPage() {
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
  void navigateToSignupPage() {
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

  /// Navigate to the settings page.
  void navigateToSettings() {
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

  /// Navigate to the previous page.
  void onCancel() {
    if (Beamer.of(context).beamingHistory.isNotEmpty) {
      Beamer.of(context).beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  /// Show or hide password input value.
  void onHidePasswordChanged(bool value) {
    setState(() => _hidePassword = value);
  }

  /// React to email changes
  void onEmailChanged(String email) {
    NavigationStateHelper.userEmailInput = email;
  }

  /// React to password changes
  void onPasswordChanged(String password) {
    NavigationStateHelper.userPasswordInput = password;
  }
}
