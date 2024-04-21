import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/dark_elevated_button.dart";
import "package:kwotes/globals/utils.dart";

class ForgotPasswordPageFooter extends StatelessWidget {
  const ForgotPasswordPageFooter({
    super.key,
    required this.emailController,
    this.isDark = false,
    this.showBackButton = true,
    this.accentColor = Colors.amber,
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
  final Color accentColor;

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
        backgroundColor: isDark ? Colors.white : null,
        elevation: 1.0,
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(
            color: accentColor.withOpacity(0.4),
          ),
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
              TablerIcons.arrow_right,
              color: accentColor,
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
      ).animate(delay: 120.ms).slideY(begin: 0.2, end: 0.0).fadeIn();
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
            iconData: TablerIcons.x,
            background: accentColor.withOpacity(0.4),
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
        ].animate(delay: 120.ms).slideY(begin: 0.2, end: 0.0).fadeIn(),
      ),
    );
  }
}
