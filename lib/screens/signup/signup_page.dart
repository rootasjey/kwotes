// ignore_for_file: unnecessary_null_comparison

import "dart:async";

import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/utils/snack.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/screens/signup/signup_page_body.dart";
import "package:kwotes/types/intents/escape_intent.dart";

class SignupPage extends StatefulWidget {
  final void Function(bool isAuthenticated)? onSignupResult;

  const SignupPage({Key? key, this.onSignupResult}) : super(key: key);

  @override
  createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  /// True if checking the server for email availability.
  bool _checkingEmail = false;

  /// True if checking the server for username availability.
  bool _checkingUsername = false;

  /// True if the server is creating the user account.
  bool _creatingAccount = false;

  /// Time to wait before checking an input value against the backend.
  final Duration _debounceDuration = const Duration(seconds: 1);

  /// Used to focus confirm password input.
  final _confirmPasswordNode = FocusNode();

  /// Used to focus password input.
  final _passwordNode = FocusNode();

  /// Used to focus username input.
  final _usernameNode = FocusNode();

  /// Error message to display next to the email input.
  /// If this is empty, there's no error for this specific input.
  String _emailErrorMessage = "";

  /// Error message to display next to the username input.
  /// If this is empty, there's no error for this specific input.
  String _usernameErrorMessage = "";

  /// Error message to display next to the confirm password input.
  /// If this is empty, there's no error for this specific input.
  String _confirmPasswordErrorMessage = "";

  /// Timer used to debounce email availability server check.
  Timer? _emailTimer;

  /// Timer used to debounce username availability server check.
  Timer? _usernameTimer;

  /// Input controller to follow, validate & submit user email value.
  final TextEditingController _emailController = TextEditingController();

  /// Input controller to follow, validate & submit username value.
  final TextEditingController _usernameController = TextEditingController();

  /// Input controller to follow, validate & submit user password value.
  final TextEditingController _passwordController = TextEditingController();

  /// Input controller to follow, validate & submit user confirm password value.
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _usernameNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_creatingAccount) {
      return LoadingView.scaffold(
        message: "accunt_creating".tr(),
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
            slivers: [
              const ApplicationBar(),
              SignupPageBody(
                checkingEmail: _checkingEmail,
                checkingUsername: _checkingUsername,
                usernameController: _usernameController,
                passwordController: _passwordController,
                onEmailChanged: onEmailChanged,
                onUsernameChanged: onUsernameChanged,
                emailErrorMessage: _emailErrorMessage,
                usernameErrorMessage: _usernameErrorMessage,
                onConfirmPasswordChanged: onConfirmPasswordChanged,
                confirmPasswordErrorMessage: _confirmPasswordErrorMessage,
                confirmPasswordController: _confirmPasswordController,
                emailController: _emailController,
                onSubmit: tryCreateAccount,
                onCancel: onCancel,
                onNavigateToSignin: onNavigateToSignin,
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 200.0)),
            ],
          ),
        ),
      ),
    );
  }

  /// Return true if all inputs (username, email, password)
  /// are in the correct format and available.
  Future<bool> checkAllInputs({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final bool passwordOk = checkConfirmPassword(
      password,
      confirmPassword,
    );
    final bool usernameOk = await checkUsername(username);
    final bool emailOk = await checkEmail(email);

    return usernameOk && emailOk && passwordOk;
  }

  /// Return true if "confirmPassword" is in a valid format & matches "password".
  /// Check for input validity: emptyness, and password === confirmPassword.
  /// Poppulate confirm password error message if there's an error
  /// in one of those steps.
  bool checkConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordErrorMessage = "password_confirm_empty_forbidden".tr();
      });

      return false;
    }

    if (confirmPassword != password) {
      setState(() {
        _confirmPasswordErrorMessage = "password_error.mismatch".tr();
      });

      return false;
    }

    setState(() {
      _confirmPasswordErrorMessage = "";
    });

    return true;
  }

  /// Check for input validity: emptyness, format, availability.
  /// Poppulate email error message if there's an error in one of those steps.
  Future<bool> checkEmail(String email) async {
    email = email.trim();

    if (email.isEmpty) {
      setState(() {
        _emailErrorMessage = "email_error.empty".tr();
      });
      return false;
    }

    final bool isWellFormatted = UserActions.checkEmailFormat(email);

    if (!isWellFormatted) {
      setState(() {
        _checkingEmail = false;
        _emailErrorMessage = "email_error.format".tr();
      });

      return false;
    }

    setState(() => _checkingEmail = true);

    final bool isAvailable = await UserActions.checkEmailAvailability(email);

    if (!isAvailable) {
      setState(() {
        _checkingEmail = false;
        _emailErrorMessage = "input.error.username_not_available".tr();
      });

      return false;
    }

    setState(() {
      _checkingEmail = false;
      _emailErrorMessage = "";
    });

    return true;
  }

  /// Check for input validity: emptyness, and password === confirmPassword.
  /// Poppulate confirm password error message if there's an error
  /// in one of those steps.
  Future<bool> checkUsername(String username) async {
    username = username.trim();

    if (username.isEmpty) {
      setState(() {
        _usernameErrorMessage = "username_error.empty".tr();
      });

      return false;
    }

    if (username.length < 3) {
      setState(() {
        _usernameErrorMessage = "username_error.minimum".tr();
      });

      return false;
    }

    if (!UserActions.checkUsernameFormat(username)) {
      setState(() {
        _usernameErrorMessage = "username_error.format".tr();
      });

      return false;
    }

    setState(() => _checkingUsername = true);

    final bool isAvailable = await UserActions.checkUsernameAvailability(
      _usernameController.text,
    );

    if (!isAvailable) {
      setState(() {
        _checkingUsername = false;
        _usernameErrorMessage = "username_not_available_args".tr(
          args: [username],
        );
      });
      return false;
    }

    setState(() {
      _checkingUsername = false;
      _usernameErrorMessage = "";
    });

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

  /// React to email changes and call `checkEmail(email)` method.
  void onEmailChanged(String email) async {
    _emailTimer?.cancel();
    _emailTimer = Timer(_debounceDuration, () => checkEmail(email));
  }

  /// React to confirm password changes
  /// and call `checkUsername(username)` method.
  void onConfirmPasswordChanged(String password, String confirmPassword) {
    checkConfirmPassword(password, confirmPassword);
  }

  /// Navigate to sign in page.
  void onNavigateToSignin() {
    Beamer.of(context).beamToNamed(SigninLocation.route);
  }

  /// React to username changes.
  /// Check for input validity: emptyness, format, availability.
  /// Poppulate username error message if there's an error in one of those steps.
  void onUsernameChanged(String username) async {
    _usernameTimer?.cancel();
    _usernameTimer = Timer(_debounceDuration, () => checkUsername(username));
  }

  /// Ask backend to create a new user account with the specified values.
  void tryCreateAccount(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    setState(() => _creatingAccount = true);

    final bool inputsAreOk = await checkAllInputs(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (!inputsAreOk) {
      setState(() => _creatingAccount = false);
      return;
    }

    try {
      // final UserNotifier userNotifier = ref.read(
      //   AppState.userProvider.notifier,
      // );

      // final CreateAccountResp createAccountResponse = await userNotifier.signUp(
      //   email: email,
      //   username: username,
      //   password: password,
      // );

      setState(() => _creatingAccount = false);

      // if (createAccountResponse.success) {
      //   if (!mounted) return;
      //   Beamer.of(context).beamToNamed(HomeLocation.route);
      //   return;
      // }

      // String message = "account_create_error".tr();
      // final error = createAccountResponse.error;

      // if (error != null && error.code != null && error.message != null) {
      //   message = "[code: ${error.code}] - ${error.message}";
      // }

      if (!mounted) {
        return;
      }

      setState(() => _creatingAccount = false);
      // Snack.error(context, message: message);
    } catch (error) {
      setState(() => _creatingAccount = false);

      if (!mounted) {
        return;
      }

      Snack.error(
        context,
        message: "account_create_error".tr(),
      );
    }
  }
}
