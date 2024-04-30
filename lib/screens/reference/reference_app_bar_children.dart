import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/reference.dart";

/// A utility class for adding children to application bar on author page.
class ReferenceAppBarChildren {
  /// Get the children for application bar on the add quote page.
  static List<Widget> getChildren(
    BuildContext context, {
    JustTheController? tooltipController,
    void Function()? onDeleteReference,
    bool canManageReference = false,
    bool isDark = false,
    void Function(Reference reference)? onTapPoster,
    Reference? reference,
  }) {
    return [
      if (reference != null && reference.urls.image.isNotEmpty)
        Hero(
          tag: reference.id,
          child: Card(
            margin: const EdgeInsets.only(right: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Ink.image(
              image: NetworkImage(reference.urls.image),
              fit: BoxFit.cover,
              child: InkWell(
                onTap: () => onTapPoster?.call(reference),
                child: const SizedBox(
                  width: 26.0,
                  height: 26.0,
                ),
              ),
            ),
          ),
        ),
      if (canManageReference)
        JustTheTooltip(
          isModal: true,
          controller: tooltipController,
          backgroundColor: isDark ? Colors.black : Colors.white,
          triggerMode: TooltipTriggerMode.tap,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: onDeleteReference,
              style: TextButton.styleFrom(
                backgroundColor: Constants.colors.error.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "reference.delete.confirm".tr(),
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
            tooltip: "reference.delete.name".tr(),
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
            icon: const Icon(TablerIcons.trash, size: 18.0),
          ),
        ),
    ];
  }
}
