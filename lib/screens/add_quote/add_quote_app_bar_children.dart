import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/globals/utils.dart";

/// A utility class for adding children to application bar on add quote page.
class AddQuoteAppBarChildren {
  /// Get the children for application bar on the add quote page.
  static List<Widget> getChildren(
    BuildContext context, {
    JustTheController? tooltipController,
    void Function()? onClearAll,
    void Function()? onDeleteQuote,
    void Function()? onResetAuthor,
    void Function()? onResetReference,
    void Function()? onDeleteAuthor,
    void Function()? onDeleteReference,
    String? clearAllTooltip,
  }) {
    return [
      if (onClearAll != null)
        IconButton(
          onPressed: onClearAll,
          tooltip: clearAllTooltip,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          icon: const Icon(TablerIcons.eraser),
        ),
      if (onResetAuthor != null)
        IconButton(
          onPressed: onResetAuthor,
          tooltip: "author.reset".tr(),
          color: Theme.of(context).textTheme.bodyMedium?.color,
          icon: const Icon(TablerIcons.rotate),
        ),
      if (onResetReference != null)
        IconButton(
          onPressed: onResetReference,
          tooltip: "reference.reset".tr(),
          color: Theme.of(context).textTheme.bodyMedium?.color,
          icon: const Icon(TablerIcons.rotate),
        ),
      if (onDeleteQuote != null)
        JustTheTooltip(
          isModal: true,
          controller: tooltipController,
          triggerMode: TooltipTriggerMode.tap,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: onDeleteQuote,
              child: Text(
                "quote.delete.confirm".tr(),
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
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
            tooltip: "quote.delete.name".tr(),
            color: Theme.of(context).textTheme.bodyMedium?.color,
            icon: const Icon(TablerIcons.trash),
          ),
        ),
      if (onDeleteAuthor != null)
        JustTheTooltip(
          isModal: true,
          controller: tooltipController,
          triggerMode: TooltipTriggerMode.tap,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: onDeleteAuthor,
              child: Text(
                "author.delete.confirm".tr(),
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
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
            tooltip: "author.delete.name".tr(),
            color: Theme.of(context).textTheme.bodyMedium?.color,
            icon: const Icon(TablerIcons.trash),
          ),
        ),
      if (onDeleteReference != null)
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
                  textStyle: const TextStyle(
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
            icon: const Icon(TablerIcons.trash),
          ),
        ),
    ];
  }

  static List<Widget> getClearAllIcon(
    BuildContext context, {
    void Function()? onClearAll,
  }) {
    return [
      IconButton(
        onPressed: onClearAll,
        tooltip: "quote.erase_all".tr(),
        color: Theme.of(context).textTheme.bodyMedium?.color,
        icon: const Icon(TablerIcons.eraser),
      ),
    ];
  }
}
