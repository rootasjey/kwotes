import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/buttons/dark_elevated_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:unicons/unicons.dart";

class SigninPageFooter extends StatelessWidget {
  /// Footer widget for the Signin page.
  const SigninPageFooter({
    super.key,
    required this.nameController,
    required this.passwordController,
    this.showBackButton = true,
    this.randomColor = Colors.amber,
    this.onSubmit,
    this.onCancel,
  });

  /// Show a back button to go back to the previous page.
  /// Hide this button when we're on mobile size screen (e.g. <=700).
  /// Default to true.
  final bool showBackButton;

  /// Random accent color.
  final Color randomColor;

  /// Callback fired to go back or exit this page.
  final void Function()? onCancel;

  /// Callback fired when the user validate their information and want to signin.
  final void Function(String name, String password)? onSubmit;

  /// Input controller for the name/email.
  final TextEditingController nameController;

  /// Input controller for the password.
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget submitButton = ElevatedButton(
      onPressed: () => onSubmit?.call(
        nameController.text,
        passwordController.text,
      ),
      style: ElevatedButton.styleFrom(
        // backgroundColor: Colors.white,
        backgroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0.0,
        foregroundColor: randomColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 20.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "signin".tr(),
            style: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              UniconsLine.arrow_right,
              color: randomColor,
            ),
          ),
        ],
      ),
    );

    if (!showBackButton) {
      return Padding(
        padding: const EdgeInsets.only(top: 36.0),
        child: submitButton,
      )
          .animate(delay: 100.ms)
          .slideY(
            begin: 0.8,
            end: 0.0,
            duration: const Duration(milliseconds: 100),
          )
          .fadeIn();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 36.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DarkElevatedButton.icon(
            elevation: 0.0,
            iconData: UniconsLine.times,
            labelValue: "cancel".tr(),
            background: randomColor.withOpacity(0.4),
            foreground: Theme.of(context).textTheme.bodyMedium?.color,
            onPressed: () => onCancel?.call(),
            minimumSize: const Size(250.0, 60.0),
          ),
          submitButton,
        ]
            .animate(delay: 100.ms, interval: 25.ms)
            .slideY(
              begin: 0.8,
              end: 0.0,
              duration: const Duration(milliseconds: 100),
            )
            .fadeIn(),
      ),
    );
  }
}
