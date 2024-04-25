import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({
    super.key,
    this.onNavigateToForgotPassword,
    this.isMobileSize = false,
    this.accentColor = Colors.amber,
  });

  /// Accent color.
  final Color accentColor;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Callback fired to the forgot password page.
  final void Function()? onNavigateToForgotPassword;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
      ),
      onPressed: onNavigateToForgotPassword,
      child: Opacity(
        opacity: 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                "password.forgot".tr(),
                style: Utils.calligraphy.code(
                  textStyle: TextStyle(
                    color: Colors.transparent,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, -5),
                        color:
                            foregroundColor?.withOpacity(0.8) ?? Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
