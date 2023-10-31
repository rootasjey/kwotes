import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({
    super.key,
    this.onNavigateToForgotPassword,
    this.isMobileSize = false,
    this.randomColor = Colors.amber,
  });

  /// A random accent color.
  final Color randomColor;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Callback fired to the forgot password page.
  final void Function()? onNavigateToForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
            backgroundColor: randomColor.withOpacity(0.1),
          ),
          onPressed: onNavigateToForgotPassword,
          child: Opacity(
            opacity: 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  "password.forgot".tr(),
                  style: Utils.calligraphy.code(
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ].animate(delay: 160.ms).slideY(begin: 0.8, end: 0.0).fadeIn(),
    );
  }
}
