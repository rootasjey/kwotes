import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/types/quote.dart";
import "package:unicons/unicons.dart";

class QuotePageActions extends StatelessWidget {
  /// Quote page actions.
  const QuotePageActions({
    super.key,
    required this.copyIcon,
    required this.quote,
    this.onCopyQuote,
    this.onToggleFavourite,
    this.onAddToList,
    this.copyTooltip = "",
  });

  /// Callback fired to copy quote's content.
  final Function()? onCopyQuote;

  /// Callback fired to toggle quote's favourite status.
  final Function()? onToggleFavourite;

  /// Callback fired to add quote to list.
  final Function()? onAddToList;

  /// Copy icon data.
  final IconData copyIcon;

  /// Quote data.
  final Quote quote;

  /// Copy icon tooltip.
  final String copyTooltip;

  @override
  Widget build(BuildContext context) {
    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);

    return Wrap(
      direction: Axis.vertical,
      children: [
        IconButton(
          color: iconColor,
          onPressed: context.beamBack,
          icon: const Icon(UniconsLine.times),
        ),
        IconButton(
          color: iconColor,
          onPressed: onCopyQuote,
          icon: Icon(copyIcon),
          tooltip: copyTooltip,
        ),
        IconButton(
          color: iconColor,
          onPressed: onToggleFavourite,
          icon: quote.starred
              ? const Icon(TablerIcons.heart_filled)
              : const Icon(UniconsLine.heart),
          tooltip:
              quote.starred ? "quote.unlike.name".tr() : "quote.like.name".tr(),
        ),
        IconButton(
          color: iconColor,
          onPressed: onAddToList,
          icon: const Icon(TablerIcons.playlist_add),
          tooltip: "list.add.to".plural(1),
        ),
      ],
    );
  }
}
