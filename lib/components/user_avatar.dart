import "package:flutter/material.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/constants.dart";

class UserAvatar extends StatelessWidget {
  /// User avatar.
  const UserAvatar({
    super.key,
    this.showBadge = false,
    this.onTapUserAvatar,
    this.margin = EdgeInsets.zero,
    this.onLongPressUserAvatar,
  });

  /// Show badge.
  final bool showBadge;

  /// Space around the avatar.
  final EdgeInsets margin;

  /// Callback fired when user avatar is tapped.
  final void Function()? onTapUserAvatar;

  /// Callback fired when user avatar is long pressed.
  final void Function()? onLongPressUserAvatar;

  @override
  Widget build(BuildContext context) {
    return BetterAvatar(
      heroTag: "user-avatar",
      radius: 16.0,
      selected: true,
      margin: margin,
      onTap: onTapUserAvatar,
      onLongPress: onLongPressUserAvatar,
      borderColor:
          showBadge ? Constants.colors.premium.withOpacity(0.6) : Colors.grey,
      imageProvider: const AssetImage(
        "assets/images/profile-picture-avocado.jpg",
      ),
      badge: showBadge
          ? Positioned(
              right: -4.0,
              bottom: -3.0,
              child: Material(
                shape: const CircleBorder(),
                color: Colors.transparent,
                child: Ink.image(
                  image: const AssetImage("assets/images/app_icon/64.png"),
                  width: 24.0,
                  height: 24.0,
                  fit: BoxFit.cover,
                  child: InkWell(
                    onTap: onTapUserAvatar,
                    onLongPress: onLongPressUserAvatar,
                    borderRadius: BorderRadius.circular(24.0),
                    splashColor: Colors.transparent,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
