import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_avatar.dart";
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
    this.onTap,
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

  /// Callback fired when the card is tapped.
  final void Function()? onTap;

  /// User account.
  final UserFirestore userFirestore;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Card(
        elevation: 0.0,
        margin: isMobileSize
            ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
            : const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                BetterAvatar(
                  heroTag: "user-avatar",
                  onTap: () {},
                  radius: 18.0,
                  imageProvider: const AssetImage(
                    "assets/images/profile-picture-avocado.jpg",
                  ),
                  margin: const EdgeInsets.only(right: 12.0),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userFirestore.name,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            color: foregroundColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        userFirestore.email,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            color: foregroundColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onTapSignout,
                  icon: const Icon(TablerIcons.arrow_right),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
