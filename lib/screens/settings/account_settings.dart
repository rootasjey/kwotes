import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_account_displayed.dart";
import "package:kwotes/types/user/user_firestore.dart";

class AccountSettings extends StatelessWidget {
  /// User account settings component.
  const AccountSettings({
    super.key,
    required this.userFirestore,
    this.animateElements = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.accentColor = Colors.blue,
    this.dividerColor,
    this.dividerHeight = 48.0,
    this.foregroundColor,
    this.onTapUpdateEmail,
    this.onTapUpdatePassword,
    this.onTapUpdateUsername,
    this.onTapSignout,
    this.onTapDeleteAccount,
    this.onTapAccountDisplayedValue,
    this.enumAccountDisplayed = EnumAccountDisplayed.name,
  });

  /// Animate elements on settings page if true.
  final bool animateElements;

  /// Dark theme if true.
  final bool isDark;

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Accent color.
  final Color accentColor;

  /// Divider color.
  final Color? dividerColor;

  /// Text foreground color.
  final Color? foregroundColor;

  /// Divider height.
  final double? dividerHeight;

  /// Enum representing the account displayed text value on settings page.
  final EnumAccountDisplayed enumAccountDisplayed;

  /// Callback fired when "Update email" button is tapped.
  final void Function()? onTapUpdateEmail;

  /// Callback fired when "Update password" button is tapped.
  final void Function()? onTapUpdatePassword;

  /// Callback fired when "Update username" button is tapped.
  final void Function()? onTapUpdateUsername;

  /// Callback fired when "sign out" button is tapped.
  final void Function()? onTapSignout;

  /// Callback fired when "Delete account" button is tapped.
  final void Function()? onTapDeleteAccount;

  /// Callback fired when the account displayed value is tapped.
  final void Function()? onTapAccountDisplayedValue;

  /// User account.
  final UserFirestore userFirestore;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
          : const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0),
      sliver: SliverList.list(children: [
        Text.rich(
          TextSpan(text: "${"account.name".tr()}: ", children: [
            TextSpan(
              text: enumAccountDisplayed == EnumAccountDisplayed.name
                  ? userFirestore.name
                  : userFirestore.email,
              recognizer: TapGestureRecognizer()
                ..onTap = onTapAccountDisplayedValue,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: accentColor,
                ),
              ),
            ),
          ]),
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: isMobileSize ? 32.0 : 32.0,
              fontWeight: isMobileSize ? FontWeight.w100 : FontWeight.w400,
              color: foregroundColor,
            ),
          ),
        )
            .animate(delay: animateElements ? 150.ms : 0.ms)
            .fadeIn(duration: animateElements ? 150.ms : 0.ms)
            .slideY(begin: 0.8, end: 0.0),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                ActionChip(
                  onPressed: onTapUpdateUsername,
                  shape: const StadiumBorder(),
                  label: Text("username.update.name".tr()),
                  labelStyle: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                  ),
                ),
                ActionChip(
                  onPressed: onTapUpdateEmail,
                  shape: const StadiumBorder(),
                  label: Text("email.update".tr()),
                  labelStyle: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                  ),
                ),
                ActionChip(
                  onPressed: onTapUpdatePassword,
                  shape: const StadiumBorder(),
                  label: Text("password.update.name".tr()),
                  labelStyle: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                  ),
                ),
                ActionChip(
                  onPressed: onTapDeleteAccount,
                  shape: const StadiumBorder(),
                  label: Text("account.delete.name".tr()),
                  labelStyle: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                  ),
                ),
                ActionChip(
                  onPressed: onTapSignout,
                  shape: const StadiumBorder(),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text("signout".tr()),
                      ),
                      Icon(
                        TablerIcons.logout,
                        color: foregroundColor?.withOpacity(0.6),
                        size: 16.0,
                      ),
                    ],
                  ),
                  labelStyle: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                  ),
                ),
              ]
                  .animate(
                    delay: animateElements ? 250.ms : 0.ms,
                    interval: animateElements ? 50.ms : 0.ms,
                  )
                  .fadeIn(duration: animateElements ? 150.ms : 0.ms)
                  .slideY(begin: 0.8, end: 0.0),
            ),
          ),
        ),
        Divider(
          height: dividerHeight,
          color: dividerColor,
        )
            .animate(delay: animateElements ? 300.ms : 0.ms)
            .fadeIn(duration: animateElements ? 250.ms : 0.ms)
            .slideY(begin: 0.8, end: 0.0),
      ]),
    );
  }
}
