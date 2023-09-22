import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/services.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/signin/signin_page_body.dart";
import "package:kwotes/types/enums/enum_app_bar_mode.dart";
import "package:kwotes/types/user/user_auth.dart";
import "package:loggy/loggy.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/router/locations/forgot_password_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/signup_location.dart";
import "package:kwotes/types/intents/escape_intent.dart";

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> with UiLoggy {
  /// True if we're trying to signin.
  bool _loading = false;

  /// Input controller to follow, validate & submit user name/email value.
  final _nameController = TextEditingController();

  /// Input controller to follow, validate & submit user password value.
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return LoadingView.scaffold(
        message: "signingin".tr(),
      );
    }

    const shortcuts = <SingleActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.escape): EscapeIntent(),
    };

    final actions = <Type, Action<Intent>>{
      EscapeIntent: CallbackAction(
        onInvoke: (Intent intent) => onCancel(),
      ),
    };

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              const ApplicationBar(
                mode: EnumAppBarMode.signin,
              ),
              SigninPageBody(
                nameController: _nameController,
                passwordController: _passwordController,
                onNavigateToForgotPassword: onNavigatetoForgotPassword,
                onNavigateToCreateAccount: onNavigateToCreateAccount,
                onCancel: onCancel,
                onSubmit: (String name, String password) => trySignin(
                  name: name,
                  password: password,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Attempt to sign in.
  void trySignin({required String name, required String password}) async {
    if (!inputValuesOk(name: name, password: password)) {
      return;
    }

    setState(() => _loading = true);

    try {
      final UserAuth? userCredential = await Utils.state.signIn(
        email: name,
        password: password,
      );

      if (userCredential == null) {
        loggy.error("account_doesnt_exist".tr());
        return;
      }

      if (!mounted) return;
      Beamer.of(context).beamToNamed(HomeLocation.route);
    } catch (error) {
      loggy.error("password_error.incorrect".tr());
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Navigate to the forgot password page.
  void onNavigatetoForgotPassword() {
    Beamer.of(context).beamToNamed(
      ForgotPasswordLocation.route,
    );
  }

  /// Navigate to the create account page.
  void onNavigateToCreateAccount() {
    Beamer.of(context).beamToNamed(
      SignupLocation.route,
    );
  }

  /// Return true if all inputs (email, password) are in the correct format.
  bool inputValuesOk({required String name, required String password}) {
    if (!UserActions.checkEmailFormat(name)) {
      loggy.error("email.not_valid".tr());
      return false;
    }

    if (password.isEmpty) {
      loggy.error("password_empty_forbidden".tr());
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
}
