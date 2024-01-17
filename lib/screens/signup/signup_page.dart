// ignore_for_file: unnecessary_null_comparison

import "dart:async";

import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/screens/signup/signup_page_body.dart";
import "package:kwotes/screens/signup/signup_page_header.dart";
import "package:kwotes/types/create_account_response.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/intents/escape_intent.dart";
import "package:loggy/loggy.dart";

class SignupPage extends StatefulWidget {
  final void Function(bool isAuthenticated)? onSignupResult;

  const SignupPage({Key? key, this.onSignupResult}) : super(key: key);

  @override
  createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with UiLoggy {
  EnumPageState _pageState = EnumPageState.idle;

  /// Time to wait before checking an input value against the backend.
  final Duration _debounceDuration = const Duration(seconds: 1);

  /// Used to focus confirm password input.
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  /// Used to focus email input.
  final FocusNode _emailFocusNode = FocusNode();

  /// Used to focus username input.
  final FocusNode _usernameFocusNode = FocusNode();

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
    _emailFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailTimer?.cancel();
    _usernameTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_pageState == EnumPageState.creatingAccount) {
      return LoadingView.scaffold(
        message: "account.creating".tr(),
      );
    }

    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Color randomColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );

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
              ApplicationBar(
                isMobileSize: isMobileSize,
                title: const SizedBox.shrink(),
              ),
              SignupPageHeader(
                isMobileSize: isMobileSize,
                onNavigateToSignin: goToSigninPage,
                randomColor: randomColor,
              ),
              SignupPageBody(
                confirmPasswordController: _confirmPasswordController,
                confirmPasswordErrorMessage: _confirmPasswordErrorMessage,
                confirmPasswordFocusNode: _confirmPasswordFocusNode,
                emailController: _emailController,
                emailErrorMessage: _emailErrorMessage,
                emailFocusNode: _emailFocusNode,
                isMobileSize: isMobileSize,
                pageState: _pageState,
                passwordController: _passwordController,
                onCancel: onCancel,
                onEmailChanged: onEmailChanged,
                onConfirmPasswordChanged: onConfirmPasswordChanged,
                onNavigateToSignin: goToSigninPage,
                onSubmit: tryCreateAccount,
                onUsernameChanged: onUsernameChanged,
                randomColor: randomColor,
                usernameController: _usernameController,
                usernameErrorMessage: _usernameErrorMessage,
                usernameFocusNode: _usernameFocusNode,
              ),
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
    final bool emailOk = await checkEmail(email);
    final bool usernameOk = await checkUsername(username);

    return usernameOk && emailOk && passwordOk;
  }

  /// Return true if "confirmPassword" is in a valid format & matches "password".
  /// Check for input validity: emptyness, and password === confirmPassword.
  /// Poppulate confirm password error message if there's an error
  /// in one of those steps.
  bool checkConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordErrorMessage = "password.error.current_empty".tr();
      });

      _confirmPasswordFocusNode.requestFocus();
      return false;
    }

    if (confirmPassword != password) {
      setState(() {
        _confirmPasswordErrorMessage = "password_error.mismatch".tr();
      });

      _confirmPasswordFocusNode.requestFocus();
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
        _emailErrorMessage = "email.error.empty".tr();
      });

      _emailFocusNode.requestFocus();
      return false;
    }

    final bool isWellFormatted = UserActions.checkEmailFormat(email);

    if (!isWellFormatted) {
      setState(() {
        _pageState = EnumPageState.idle;
        _emailErrorMessage = "email.error.not_valid".tr();
      });

      _emailFocusNode.requestFocus();
      return false;
    }

    setState(() => _pageState = EnumPageState.checkingEmail);

    final bool isAvailable = await UserActions.checkEmailAvailability(email);

    if (!isAvailable) {
      setState(() {
        _pageState = EnumPageState.idle;
        _emailErrorMessage = "input.error.username_not_available".tr();
      });

      _emailFocusNode.requestFocus();
      return false;
    }

    setState(() {
      _pageState = EnumPageState.idle;
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
        _usernameErrorMessage = "username.error.empty".tr();
      });

      _usernameFocusNode.requestFocus();
      return false;
    }

    if (username.length < 3) {
      setState(() {
        _usernameErrorMessage = "username.error.minimum_length".tr();
      });

      _usernameFocusNode.requestFocus();
      return false;
    }

    if (!UserActions.checkUsernameFormat(username)) {
      setState(() {
        _usernameErrorMessage = "username_error.invalid".tr();
      });

      _usernameFocusNode.requestFocus();
      return false;
    }

    setState(() => _pageState = EnumPageState.checkingUsername);

    final bool isAvailable = await UserActions.checkUsernameAvailability(
      _usernameController.text,
    );

    if (!isAvailable) {
      setState(() {
        _pageState = EnumPageState.idle;
        _usernameErrorMessage = "username.error.already_taken".tr(
          args: [username],
        );
      });

      _usernameFocusNode.requestFocus();
      return false;
    }

    setState(() {
      _pageState = EnumPageState.idle;
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
    setState(() => _emailErrorMessage = "");
    _emailTimer?.cancel();
    _emailTimer = Timer(_debounceDuration, () => checkEmail(email));
  }

  /// React to confirm password changes
  /// and call `checkUsername(username)` method.
  void onConfirmPasswordChanged(String password, String confirmPassword) {
    setState(() => _confirmPasswordErrorMessage = "");
    checkConfirmPassword(password, confirmPassword);
  }

  /// Navigate to sign in page.
  void goToSigninPage() {
    final BeamerDelegate beamer = Beamer.of(context);
    final BeamState beamState = beamer.currentBeamLocation.state as BeamState;
    final List<String> pathSegments = beamState.pathPatternSegments;
    final String prefix = pathSegments.first;

    if (prefix == "d") {
      beamer.beamToNamed(DashboardContentLocation.signinRoute);
      return;
    }

    beamer.root.beamToNamed(SigninLocation.route);
  }

  /// React to username changes.
  /// Check for input validity: emptyness, format, availability.
  /// Poppulate username error message if there's an error in one of those steps.
  void onUsernameChanged(String username) async {
    setState(() => _usernameErrorMessage = "");
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
    setState(() => _pageState = EnumPageState.creatingAccount);

    final bool inputsAreOk = await checkAllInputs(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (!inputsAreOk) {
      setState(() => _pageState = EnumPageState.idle);
      return;
    }

    try {
      final CreateAccountResponse createAccountResponse =
          await Utils.state.signUp(
        email: email,
        username: username,
        password: password,
      );

      setState(() => _pageState = EnumPageState.idle);

      if (createAccountResponse.success) {
        if (!mounted) return;
        Beamer.of(context)
            .beamToReplacementNamed(DashboardContentLocation.route);
        return;
      }

      String message = "account_create_error".tr();
      final error = createAccountResponse.error;

      if (error != null && error.code != null && error.message != null) {
        message = "[code: ${error.code}] - ${error.message}";
      }

      if (!mounted) return;
      Utils.graphic.showSnackbar(
        context,
        message: message,
      );
    } catch (error) {
      if (!mounted) return;
      loggy.error(error);

      Utils.graphic.showSnackbar(
        context,
        message: "account_create_error".tr(),
      );
      setState(() => _pageState = EnumPageState.idle);
    }
  }
}
