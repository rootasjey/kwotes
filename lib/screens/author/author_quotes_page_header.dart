import "package:flutter/material.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

class AuthorQuotesPageHeader extends StatelessWidget {
  const AuthorQuotesPageHeader({
    super.key,
    required this.author,
    this.isMobileSize = false,
    this.onDoubleTapName,
    this.onTapAvatar,
    this.onTapName,
  });

  /// Author data for this component.
  final Author author;

  /// Whether the screen is narrow.
  final bool isMobileSize;

  /// Callback fired when avatar is tapped.
  final void Function()? onTapAvatar;

  /// Callback fired when name is tapped.
  final void Function()? onTapName;

  /// Callback fired when name is double tapped.
  final void Function()? onDoubleTapName;

  @override
  Widget build(BuildContext context) {
    final Object imageProvider = author.urls.image.isNotEmpty
        ? NetworkImage(author.urls.image)
        : const AssetImage("assets/images/profile-picture-avocado.png");

    return PageAppBar(
      axis: Axis.horizontal,
      isMobileSize: isMobileSize,
      toolbarHeight: 74.0,
      children: [
        BetterAvatar(
          imageProvider: imageProvider as ImageProvider,
          radius: 16.0,
          avatarMargin: EdgeInsets.zero,
          margin: const EdgeInsets.only(left: 6.0, right: 12.0),
          onTap: onTapAvatar,
        ),
        Expanded(
          child: InkWell(
            onTap: onTapName,
            onDoubleTap: onDoubleTapName,
            child: Text(
              author.name,
              style: Utils.calligraphy.title(
                textStyle: TextStyle(
                  fontSize: isMobileSize ? 32.0 : 42.0,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
