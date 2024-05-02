import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

/// A utility class for adding children to application bar on author page.
class AuthorAppBarChildren {
  /// Get the children for application bar on the add quote page.
  static List<Widget> getChildren(
    BuildContext context, {
    bool isDark = false,
    JustTheController? tooltipController,
    void Function()? onDeleteAuthor,
    Author? author,
    bool canManageAuthor = false,
    final void Function()? onTapAvatar,
    void Function()? onGoToEditPage,
  }) {
    return [
      if (author != null && author.urls.image.isNotEmpty)
        BetterAvatar(
          radius: 14.0,
          margin: EdgeInsets.zero,
          avatarMargin: EdgeInsets.zero,
          onTap: onTapAvatar,
          heroTag: author.id,
          imageProvider: NetworkImage(author.urls.image),
        ),
      if (canManageAuthor) ...[
        JustTheTooltip(
          isModal: true,
          backgroundColor: isDark ? Colors.black : Colors.white,
          controller: tooltipController,
          triggerMode: TooltipTriggerMode.tap,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: onDeleteAuthor,
              style: TextButton.styleFrom(
                backgroundColor: Constants.colors.error.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "author.delete.confirm".tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    color: Constants.colors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          child: CircleButton(
            radius: 14.0,
            onTap: () => tooltipController?.showTooltip(),
            backgroundColor: Constants.colors.delete.withOpacity(0.1),
            tooltip: "author.delete.name".tr(),
            icon: Icon(
              TablerIcons.trash,
              size: 18.0,
              color: Constants.colors.delete,
            ),
          ),
        ),
        CircleButton(
          radius: 14.0,
          onTap: onGoToEditPage,
          tooltip: "author.edit.name".tr(),
          backgroundColor: Constants.colors.edit.withOpacity(0.1),
          icon: Icon(
            TablerIcons.pencil,
            size: 18.0,
            color: Constants.colors.edit,
          ),
        ),
      ]
    ];
  }
}
