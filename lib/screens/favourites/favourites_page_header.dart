import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

/// Favourites page header.
class FavouritesPageHeader extends StatelessWidget {
  /// Header part of favourites page.
  const FavouritesPageHeader({
    super.key,
    this.isMobileSize = false,
  });

  /// Reduce font size if true.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMobileSize
          ? const EdgeInsets.only(left: 6.0, bottom: 24.0)
          : const EdgeInsets.only(bottom: 42.0),
      child: Hero(
        tag: "favourites",
        child: Material(
          color: Colors.transparent,
          child: Text.rich(
            TextSpan(text: "favourites.name".tr(), children: [
              TextSpan(
                text: ".",
                style: TextStyle(
                  color: Constants.colors.likes,
                ),
              ),
            ]),
            style: Utils.calligraphy.title(
              textStyle: TextStyle(
                fontSize: isMobileSize ? 42.0 : 74.0,
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
    );
  }
}
