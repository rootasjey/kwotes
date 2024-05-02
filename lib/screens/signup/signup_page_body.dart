import "package:flutter/material.dart";
import "package:kwotes/screens/signup/signup_page_email_input.dart";
import "package:kwotes/screens/signup/signup_page_footer.dart";
import "package:kwotes/screens/signup/signup_page_password_inputs.dart";
import "package:kwotes/screens/signup/signup_page_username_input.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class SignupPageBody extends StatelessWidget {
  const SignupPageBody({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.emailErrorMessage,
    required this.usernameErrorMessage,
    required this.confirmPasswordController,
    required this.emailController,
    this.hidePassword = true,
    this.isMobileSize = false,
    this.pageState = EnumPageState.idle,
    this.accentColor = Colors.amber,
    this.onSubmit,
    this.onUsernameChanged,
    this.onPasswordChanged,
    this.onNavigateToForgotPassword,
    this.onNavigateToSignin,
    this.onCancel,
    this.onConfirmPasswordChanged,
    this.onEmailChanged,
    this.onHidePasswordChanged,
    this.confirmPasswordErrorMessage = "",
    this.confirmPasswordFocusNode,
    this.emailFocusNode,
    this.passwordFocusNode,
    this.usernameFocusNode,
  });

  /// Hide password input if true.
  final bool hidePassword;

  /// Adapt user interface to the screen's size.
  /// True if the screen is small (e.g. <= 700 px).
  final bool isMobileSize;

  /// Accent color.
  final Color accentColor;

  /// Page's state (e.g. idle, checking username, etc.).
  final EnumPageState pageState;

  /// Used to focus confirm password input.
  final FocusNode? confirmPasswordFocusNode;

  /// Used to focus email input.
  final FocusNode? emailFocusNode;

  /// Used to focus password input.
  final FocusNode? passwordFocusNode;

  /// Used to focus username input.
  final FocusNode? usernameFocusNode;

  /// Callback fired to go back or exit this page.
  final void Function()? onCancel;

  /// Callback fired when typed confirm password changed.
  final void Function(
    String password,
    String confirmPassword,
  )? onConfirmPasswordChanged;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Callback called when the user wants to hide/show password.
  final void Function(bool value)? onHidePasswordChanged;

  /// Callback fired to the forgot password page.
  final void Function()? onNavigateToForgotPassword;

  /// Callback fired to the create account page.
  final void Function()? onNavigateToSignin;

  /// Callback fired when typed password changed.
  final void Function(String password)? onPasswordChanged;

  /// Callback fired when the user validate their information and want to signin.
  final void Function(
    String name,
    String email,
    String password,
    String confirmPassword,
  )? onSubmit;

  /// Callback fired when typed name changed.
  final void Function(String name)? onUsernameChanged;

  /// Error message about the confirm password.
  final String confirmPasswordErrorMessage;

  /// Error message about the email.
  final String emailErrorMessage;

  /// Error message about the username.
  final String usernameErrorMessage;

  /// Input controller for the confirm password.
  final TextEditingController confirmPasswordController;

  /// Input controller for the email.
  final TextEditingController emailController;

  /// Input controller for the password.
  final TextEditingController passwordController;

  /// Input controller for the username.
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          padding: EdgeInsets.only(
            top: isMobileSize ? 0.0 : 40.0,
            left: 24.0,
            right: 24.0,
            bottom: 200.0,
          ),
          width: 500.0,
          child: Column(
            children: [
              SignupPageUsernameInput(
                focusNode: usernameFocusNode,
                onUsernameChanged: onUsernameChanged,
                pageState: pageState,
                accentColor: accentColor,
                usernameController: usernameController,
                usernameErrorMessage: usernameErrorMessage,
                margin: const EdgeInsets.only(top: 24.0, bottom: 24.0),
              ),
              SignupPageEmailInput(
                focusNode: emailFocusNode,
                emailController: emailController,
                randomColor: accentColor,
                onEmailChanged: onEmailChanged,
                emailErrorMessage: emailErrorMessage,
              ),
              SignupPagePasswordInputs(
                confirmPasswordController: confirmPasswordController,
                confirmPasswordErrorMessage: confirmPasswordErrorMessage,
                confirmPasswordFocusNode: confirmPasswordFocusNode,
                emailController: emailController,
                hidePassword: hidePassword,
                isMobileSize: isMobileSize,
                onConfirmPasswordChanged: onConfirmPasswordChanged,
                onHidePasswordChanged: onHidePasswordChanged,
                onPasswordChanged: onPasswordChanged,
                onSubmit: onSubmit,
                passwordController: passwordController,
                randomColor: accentColor,
                usernameController: usernameController,
              ),
              SignupPageFooter(
                showBackButton: !isMobileSize,
                onCancel: onCancel,
                onSubmit: onSubmit,
                confirmPasswordController: confirmPasswordController,
                emailController: emailController,
                passwordController: passwordController,
                accentColor: accentColor,
                usernameController: usernameController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
