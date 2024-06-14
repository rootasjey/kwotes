import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/better_tooltip.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/user/user_firestore.dart";

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userFirestore,
    this.isMobileSize = false,
    this.isDark = false,
    this.foregroundColor,
    this.accentColor,
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
  final Color? accentColor;

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
    final bool isMobile = Utils.graphic.isMobile();
    final double verticalButtonPadding = isMobile ? 8.0 : 16.0;
    final EdgeInsets padding = isMobileSize
        ? EdgeInsets.only(
            top: Utils.graphic.getDesktopPadding(),
            left: 16.0,
            right: 24.0,
          )
        : EdgeInsets.only(
            top: Utils.graphic.getDesktopPadding(),
            left: 48.0,
            right: 76.0,
          );

    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BetterAvatar(
            heroTag: "user-avatar",
            onTap: onTapUserAvatar,
            radius: 16.0,
            selected: true,
            margin: EdgeInsets.zero,
            borderColor: Colors.grey,
            imageProvider: const AssetImage(
              "assets/images/profile-picture-avocado.jpg",
            ),
          ),
          BetterTooltip(
            tooltipString: "quote.new".tr(),
            child: TextButton.icon(
              onPressed: () {
                onTapNewQuoteButton?.call(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: isDark ? Colors.black : Colors.white,
                foregroundColor: foregroundColor,
                minimumSize: const Size(0.0, 0.0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(
                  vertical: verticalButtonPadding,
                  horizontal: 24.0,
                ),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(TablerIcons.plus, size: 16.0),
              label: Text(
                "quote.name".tr(),
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    // fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
