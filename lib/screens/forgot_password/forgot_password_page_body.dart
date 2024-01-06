import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page_email_input.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page_footer.dart";

class ForgotPasswordPageBody extends StatelessWidget {
  const ForgotPasswordPageBody({
    super.key,
    required this.emailController,
    required this.emailErrorMessage,
    this.isDark = false,
    this.isMobileSize = false,
    this.randomColor = Colors.amber,
    this.onCancel,
    this.onEmailChanged,
    this.onSubmit,
  });

  /// Whether the page is in dark mode.
  final bool isDark;

  /// Adapt the user interface to small screens if true.
  final bool isMobileSize;

  /// Random accent color.
  final Color randomColor;

  /// Callback fired to go back or exit this page.
  final void Function()? onCancel;

  /// Callback fired when typed email changed.
  final void Function(String email)? onEmailChanged;

  /// Callback fired when the user validate their information and want to signin.
  final void Function(String email)? onSubmit;

  /// Error message about the email.
  final String emailErrorMessage;

  /// Input controller for the email.
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          padding: const EdgeInsets.only(
            top: 40.0,
            left: 24.0,
            right: 24.0,
            bottom: 54.0,
          ),
          width: 600.0,
          child: Column(
            children: [
              ForgotPasswordPageEmailInput(
                emailErrorMessage: emailErrorMessage,
                emailController: emailController,
                onEmailChanged: onEmailChanged,
                randomColor: randomColor,
              ),
              ForgotPasswordPageFooter(
                isDark: isDark,
                emailController: emailController,
                onCancel: onCancel,
                onSubmit: onSubmit,
                randomColor: randomColor,
                showBackButton: !isMobileSize,
              ),
            ].animate(delay: 75.ms).slideY(begin: 0.8, end: 0.0).fadeIn(),
          ),
        ),
      ),
    );
  }
}
