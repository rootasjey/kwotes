import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/dark_elevated_button.dart";
import "package:kwotes/globals/utils.dart";

class SignupPageFooter extends StatelessWidget {
  const SignupPageFooter({
    super.key,
    required this.confirmPasswordController,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    this.showBackButton = true,
    this.randomColor = Colors.amber,
    this.onCancel,
    this.onSubmit,
  });

  /// Show a back button to go back to the previous page.
  /// Hide this button when we're on mobile size screen (e.g. <=700).
  /// Default to true.
  final bool showBackButton;

  /// A random accent color.
  final Color randomColor;

  /// Callback fired to cancel the current action.
  final void Function()? onCancel;

  /// Callback fired when the user validate their information and want to signin.
  final void Function(
    String name,
    String email,
    String password,
    String confirmPassword,
  )? onSubmit;

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget submitButton = ElevatedButton(
      onPressed: () => onSubmit?.call(
        usernameController.text,
        emailController.text,
        passwordController.text,
        confirmPasswordController.text,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.white : null,
        elevation: 4.0,
        foregroundColor: randomColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 18.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "account.create".tr(),
            style: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(TablerIcons.arrow_right),
          ),
        ],
      ),
    );

    if (!showBackButton) {
      return Padding(
        padding: const EdgeInsets.only(top: 36.0),
        child: submitButton,
      ).animate(delay: 100.ms).slideY(begin: 0.8, end: 0.0).fadeIn();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DarkElevatedButton.icon(
            elevation: 0.0,
            iconData: TablerIcons.x,
            labelValue: "cancel".tr(),
            foreground: Theme.of(context).textTheme.bodyMedium?.color,
            background: randomColor.withOpacity(0.4),
            onPressed: onCancel,
            minimumSize: const Size(250.0, 60.0),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: submitButton,
            ),
          ),
        ].animate(delay: 100.ms).slideY(begin: 0.8, end: 0.0).fadeIn(),
      ),
    );
  }
}
