import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_accunt_displayed.dart";
import "package:kwotes/types/user/user_firestore.dart";

class AccountSettings extends StatelessWidget {
  /// User account settings component.
  const AccountSettings({
    super.key,
    required this.userFirestore,
    this.isMobileSize = false,
    this.onTapUpdateEmail,
    this.onTapUpdatePassword,
    this.onTapUpdateUsername,
    this.onTapLogout,
    this.onTapDeleteAccount,
    this.onTapAccountDisplayedValue,
    this.enumAccountDisplayed = EnumAccountDisplayed.name,
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Enum representing the account displayed text value on settings page.
  final EnumAccountDisplayed enumAccountDisplayed;

  /// Callback fired when "Update email" button is tapped.
  final void Function()? onTapUpdateEmail;

  /// Callback fired when "Update password" button is tapped.
  final void Function()? onTapUpdatePassword;

  /// Callback fired when "Update username" button is tapped.
  final void Function()? onTapUpdateUsername;

  /// Callback fired when "Logout" button is tapped.
  final void Function()? onTapLogout;

  /// Callback fired when "Delete account" button is tapped.
  final void Function()? onTapDeleteAccount;

  /// Callback fired when the account displayed value is tapped.
  final void Function()? onTapAccountDisplayedValue;

  final UserFirestore userFirestore;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color accentColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );

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
              fontSize: isMobileSize ? 42.0 : 72.0,
              fontWeight: FontWeight.w100,
              color: foregroundColor,
            ),
          ),
        )
            .animate(delay: 150.ms)
            .fadeIn(duration: 150.ms)
            .slideY(begin: 0.8, end: 0.0, duration: 150.ms),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            ActionChip(
              onPressed: onTapUpdateUsername,
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
              label: Text("account.delete.name".tr()),
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: foregroundColor?.withOpacity(0.6),
                ),
              ),
            ),
            ActionChip(
              onPressed: onTapLogout,
              label: Text("logout".tr()),
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: foregroundColor?.withOpacity(0.6),
                ),
              ),
            ),
          ]
              .animate(delay: 250.ms, interval: 50.ms)
              .fadeIn(duration: 150.ms)
              .slideY(begin: 0.8, end: 0.0),
        ),
        const Divider(
          height: 48.0,
        )
            .animate(delay: 300.ms)
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.8, end: 0.0, duration: 250.ms),
      ]),
    );
  }
}
