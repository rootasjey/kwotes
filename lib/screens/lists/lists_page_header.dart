import "dart:math";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

/// Lists page header.
class ListsPageHeader extends StatelessWidget {
  const ListsPageHeader({
    super.key,
    this.isMobileSize = false,
    this.showCreate = false,
    this.accentColor,
    this.onTapNewListButton,
  });

  /// Adapt UI for mobile size.
  final bool isMobileSize;

  /// Either show create or close button.
  final bool showCreate;

  /// Accent color.
  final Color? accentColor;

  /// Callback fired when new list button is tapped.
  final void Function()? onTapNewListButton;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: "lists",
            child: Material(
              color: Colors.transparent,
              child: Text.rich(
                TextSpan(text: "lists.name".tr(), children: [
                  TextSpan(
                    text: ".",
                    style: TextStyle(
                      color: accentColor,
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
          TextButton.icon(
            onPressed: onTapNewListButton,
            style: TextButton.styleFrom(
              foregroundColor: foregroundColor,
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 24.0,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: accentColor ?? Colors.transparent,
                  width: 1.0,
                ),
              ),
            ),
            icon: Icon(
              TablerIcons.plus,
              size: 16.0,
              color: foregroundColor?.withOpacity(0.6),
            )
                .animate(
                  target: showCreate ? 0.0 : 1.0,
                )
                .rotate(
                  begin: 0.13 * (pi / 3),
                  curve: Curves.decelerate,
                ),
            label: Text(
              showCreate ? "close".tr() : "list.new".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: foregroundColor?.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
