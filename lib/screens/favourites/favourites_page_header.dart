import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

/// Favourites page header.
class FavouritesPageHeader extends StatelessWidget {
  /// Header part of favourites page.
  const FavouritesPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 48.0, bottom: 42.0),
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
                  fontSize: 74.0,
                  fontWeight: FontWeight.w200,
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
      ),
    );
  }
}
