import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

/// Lists page header.
class ListsPageHeader extends StatelessWidget {
  const ListsPageHeader({
    super.key,
    this.isMobileSize = false,
  });

  /// Adapt UI for mobile size.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Hero(
        tag: "lists",
        child: Material(
          color: Colors.transparent,
          child: Text.rich(
            TextSpan(text: "lists.name".tr(), children: [
              TextSpan(
                text: ".",
                style: TextStyle(
                  color: Constants.colors.inValidation,
                ),
              ),
            ]),
            style: Utils.calligraphy.title(
              textStyle: TextStyle(
                fontSize: isMobileSize ? 74.0 : 124.0,
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
