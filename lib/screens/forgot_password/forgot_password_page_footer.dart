import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/buttons/dark_elevated_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:unicons/unicons.dart";

class ForgotPasswordPageFooter extends StatelessWidget {
  const ForgotPasswordPageFooter({
    super.key,
    required this.emailController,
    this.isDark = false,
    this.showBackButton = true,
    this.randomColor = Colors.amber,
    this.onCancel,
    this.onSubmit,
  });

  /// Whether the page is in dark mode.
  final bool isDark;

  /// Show a back button to go back to the previous page.
  /// Hide this button when we're on mobile size screen (e.g. <=700).
  /// Default to true.
  final bool showBackButton;

  /// Random accent color.
  final Color randomColor;

  /// Callback fired to go back or exit this page.
  final void Function()? onCancel;

  /// Callback fired when the user validate their information and want to signin.
  final void Function(String email)? onSubmit;

  /// Input controller for the name/email.
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final Widget submitButton = ElevatedButton(
      onPressed: () => onSubmit?.call(emailController.text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0.0,
        foregroundColor: randomColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 23.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "email.send_reset_link".tr(),
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
        padding: const EdgeInsets.only(
          top: 24.0,
        ),
        child: submitButton,
      ).animate(delay: 180.ms).slideY(begin: 0.8, end: 0.0).fadeIn();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        left: 12.0,
        right: 4.0,
        bottom: 54.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DarkElevatedButton.icon(
            elevation: 0.0,
            labelValue: "cancel".tr(),
            iconData: UniconsLine.times,
            background: randomColor.withOpacity(0.4),
            foreground: Theme.of(context).textTheme.bodyMedium?.color,
            onPressed: () => onCancel?.call(),
            minimumSize: const Size(250.0, 60.0),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: submitButton,
            ),
          ),
        ].animate(delay: 180.ms).slideY(begin: 0.8, end: 0.0).fadeIn(),
      ),
    );
  }
}
