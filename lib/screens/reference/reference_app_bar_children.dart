import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:unicons/unicons.dart";

/// A utility class for adding children to application bar on author page.
class ReferenceAppBarChildren {
  /// Get the children for application bar on the add quote page.
  static List<Widget> getChildren(
    BuildContext context, {
    JustTheController? tooltipController,
    void Function()? onDeleteReference,
  }) {
    return [
      JustTheTooltip(
        isModal: true,
        controller: tooltipController,
        triggerMode: TooltipTriggerMode.tap,
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: onDeleteReference,
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
        child: IconButton(
          onPressed: () {
            tooltipController?.showTooltip();
          },
          tooltip: "reference.delete.name".tr(),
          color: Theme.of(context).textTheme.bodyMedium?.color,
          icon: const Icon(UniconsLine.trash),
        ),
      ),
    ];
  }
}
