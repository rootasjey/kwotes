import "package:flutter/material.dart";
import "package:kwotes/screens/signin/forgot_password_button.dart";
import "package:kwotes/screens/signin/signin_page_footer.dart";
import "package:kwotes/screens/signin/signin_page_email_input.dart";
import "package:kwotes/screens/signin/signin_page_password_input.dart";

/// Body widget for the Sign in page.
class SigninPageBody extends StatelessWidget {
  const SigninPageBody({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.isMobileSize = false,
    this.randomColor = Colors.amber,
    this.emailFocusNode,
    this.passwordFocusNode,
    this.onCancel,
    this.onNameChanged,
    this.onNavigateToCreateAccount,
    this.onNavigateToForgotPassword,
    this.onPasswordChanged,
    this.onSubmit,
  });

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Random accent color.
  final Color randomColor;

  /// Used to focus email input (e.g. after error).
  final FocusNode? emailFocusNode;

  /// Used to focus password input (e.g. after error).
  final FocusNode? passwordFocusNode;

  /// Callback fired to go back or exit this page.
  final void Function()? onCancel;

  /// Callback fired when typed name changed.
  final void Function(String name)? onNameChanged;

  /// Callback fired to the create account page.
  final void Function()? onNavigateToCreateAccount;

  /// Callback fired to the forgot password page.
  final void Function()? onNavigateToForgotPassword;

  /// Callback fired when typed password changed.
  final void Function(String password)? onPasswordChanged;

  /// Callback fired when the user validate their information and want to signin.
  final void Function(String name, String password)? onSubmit;

  /// Input controller for the name/email.
  final TextEditingController emailController;

  /// Input controller for the password.
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          padding: EdgeInsets.only(
            top: isMobileSize ? 0.0 : 40.0,
            left: 24.0,
            right: 24.0,
            bottom: 54.0,
          ),
          width: 600.0,
          child: Column(
            children: <Widget>[
              SigninPageEmailInput(
                focusNode: emailFocusNode,
                emailController: emailController,
                randomColor: randomColor,
              ),
              SigninPagePasswordInput(
                focusNode: passwordFocusNode,
                nameController: emailController,
                onSubmit: onSubmit,
                passwordController: passwordController,
                randomColor: randomColor,
              ),
              ForgotPasswordButton(
                isMobileSize: isMobileSize,
                onNavigateToForgotPassword: onNavigateToForgotPassword,
                randomColor: randomColor,
              ),
              SigninPageFooter(
                nameController: emailController,
                onCancel: onCancel,
                onSubmit: onSubmit,
                passwordController: passwordController,
                showBackButton: !isMobileSize,
                randomColor: randomColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
