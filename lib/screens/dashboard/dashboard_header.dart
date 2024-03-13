import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_avatar.dart";
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
    this.onTapNewQuoteButton,
    this.onTapUserAvatar,
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

  /// Callback fired when new quote button is tapped.
  final void Function(BuildContext context)? onTapNewQuoteButton;

  /// Callback fired when user avatar is tapped.
  final void Function()? onTapUserAvatar;

  /// User data.
  final UserFirestore userFirestore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0)
          : const EdgeInsets.only(
              top: 24.0,
              left: 48.0,
              right: 76.0,
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BetterAvatar(
            heroTag: "user-avatar",
            onTap: onTapUserAvatar,
            radius: 16.0,
            imageProvider: const AssetImage(
              "assets/images/profile-picture-avocado.png",
            ),
          ),
          TextButton.icon(
            onPressed: () {
              onTapNewQuoteButton?.call(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: isDark ? Colors.black : Colors.white,
              foregroundColor: foregroundColor,
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 24.0,
              ),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(TablerIcons.plus, size: 16.0),
            label: Text(
              "quote.name".tr(),
              style: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
