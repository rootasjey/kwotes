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
    this.hidePassword = true,
    this.isDark = false,
    this.isMobileSize = false,
    this.accentColor = Colors.amber,
    this.emailFocusNode,
    this.passwordFocusNode,
    this.onCancel,
    this.onEmailChanged,
    this.onHidePasswordChanged,
    this.onNavigateToCreateAccount,
    this.onNavigateToForgotPassword,
    this.onPasswordChanged,
    this.onSubmit,
  });

  /// Hide password input if true.
  final bool hidePassword;

  /// Whether the page is in dark mode.
  final bool isDark;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Accent color.
  final Color accentColor;

  /// Used to focus email input (e.g. after error).
  final FocusNode? emailFocusNode;

  /// Used to focus password input (e.g. after error).
  final FocusNode? passwordFocusNode;

  /// Callback fired to go back or exit this page.
  final void Function()? onCancel;

  /// Callback fired when typed email changed.
  final void Function(String name)? onEmailChanged;

  /// Callback called when the user wants to hide/show password.
  final void Function(bool value)? onHidePasswordChanged;

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
            bottom: isMobileSize ? 54.0 : 160.0,
          ),
          width: 500.0,
          child: Column(
            children: <Widget>[
              SigninPageEmailInput(
                accentColor: accentColor,
                borderRadius: BorderRadius.circular(36.0),
                focusNode: emailFocusNode,
                emailController: emailController,
                onEmailChanged: onEmailChanged,
                margin: const EdgeInsets.only(
                  top: 36.0,
                  bottom: 24.0,
                ),
              ),
              SigninPagePasswordInput(
                accentColor: accentColor,
                focusNode: passwordFocusNode,
                hidePassword: hidePassword,
                nameController: emailController,
                onHidePasswordChanged: onHidePasswordChanged,
                onPasswordChanged: onPasswordChanged,
                onSubmit: onSubmit,
                passwordController: passwordController,
              ),
              ForgotPasswordButton(
                accentColor: accentColor,
                isMobileSize: isMobileSize,
                onNavigateToForgotPassword: onNavigateToForgotPassword,
              ),
              SigninPageFooter(
                accentColor: accentColor,
                isDark: isDark,
                nameController: emailController,
                onCancel: onCancel,
                onSubmit: onSubmit,
                passwordController: passwordController,
                showBackButton: !isMobileSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
