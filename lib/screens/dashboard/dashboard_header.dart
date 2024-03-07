import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/user/user_firestore.dart";

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userFirestore,
    this.isMobileSize = false,
    this.isDark = false,
    this.foregroundColor,
    this.randomColor,
    this.onTapUsername,
  });

  /// True if the screen size is similar to a mobile.
  /// Adapt UI accordingly.
  final bool isMobileSize;

  /// True if the theme is dark.
  final bool isDark;

  /// Foreground color.
  final Color? foregroundColor;

  /// Random color.
  final Color? randomColor;

  /// Callback fired when username is tapped.
  /// Show signout bottom sheet.
  final void Function(BuildContext context)? onTapUsername;

  /// User data.
  final UserFirestore userFirestore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 12.0, left: 24.0)
          : const EdgeInsets.only(
              top: 12.0,
              left: 48.0,
            ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "${"welcome_back".tr()},\n",
              style: TextStyle(
                color: foregroundColor?.withOpacity(0.4),
                fontWeight: FontWeight.w100,
                fontSize: isMobileSize ? 16.0 : 24.0,
              ),
            ),
            TextSpan(
              text: userFirestore.name,
              style: TextStyle(
                color: foregroundColor?.withOpacity(0.7),
                fontWeight: FontWeight.w800,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  onTapUsername?.call(context);
                },
            ),
            TextSpan(
              text: ".",
              style: Utils.calligraphy.title(
                textStyle: TextStyle(
                  color: randomColor,
                ),
              ),
            ),
          ],
        ),
        style: Utils.calligraphy.body(
          textStyle: TextStyle(
            fontSize: isMobileSize ? 42.0 : 74.0,
            height: 0.8,
          ),
        ),
      ),
    );
  }
}
