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
      radius: 12.0,
      selected: true,
      margin: margin,
      onTap: onTapUserAvatar,
      onLongPress: onLongPressUserAvatar,
      borderColor: Constants.colors.inValidation,
      imageProvider: const AssetImage(
        "assets/images/orange-profile-picture.png",
      ),
      badge: showBadge
          ? Positioned(
              right: -2.0,
              bottom: 6.0,
              child: Material(
                shape: const CircleBorder(),
                color: Colors.transparent,
                child: Ink.image(
                  image: const AssetImage("assets/images/app_icon/64.png"),
                  width: 18.0,
                  height: 18.0,
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
