import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class SigninPageFooter extends StatelessWidget {
  /// Footer widget for the Signin page.
  const SigninPageFooter({
    super.key,
    required this.nameController,
    required this.passwordController,
    this.isDark = false,
    this.showBackButton = true,
    this.accentColor = Colors.amber,
    this.onSubmit,
    this.onCancel,
  });

  /// Whether the page is in dark mode.
  final bool isDark;

  /// Show a back button to go back to the previous page.
  /// Hide this button when we're on mobile size screen (e.g. <=700).
  /// Default to true.
  final bool showBackButton;

  /// Accent color.
  final Color accentColor;

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
    final Widget submitButton = ElevatedButton(
      onPressed: () => onSubmit?.call(
        nameController.text,
        passwordController.text,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? accentColor.withOpacity(0.1) : null,
        elevation: 1.0,
        enableFeedback: true,
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
            "signin.name".tr(),
            style: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontSize: 14.0,
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

    if (!showBackButton || !context.canBeamBack) {
      return Padding(
        padding: const EdgeInsets.only(top: 36.0),
        child: submitButton,
      )
          .animate(delay: 125.ms)
          .slideY(
            begin: 0.2,
            end: 0.0,
          )
          .fadeIn();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 36.0,
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: accentColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 42.0,
                vertical: 14.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
                side: BorderSide(
                  color: accentColor.withOpacity(0.4),
                ),
              ),
            ),
            child: Text(
              "cancel".tr(),
              style: Utils.calligraphy.body(
                textStyle: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: submitButton,
            ),
          ),
        ],
      ),
    );
  }
}
