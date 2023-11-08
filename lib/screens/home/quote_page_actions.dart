import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/like_button.dart";
import "package:kwotes/types/quote.dart";
import "package:unicons/unicons.dart";

class QuotePageActions extends StatelessWidget {
  /// Quote page actions.
  const QuotePageActions({
    super.key,
    required this.copyIcon,
    required this.quote,
    this.direction = Axis.vertical,
    this.authenticated = false,
    this.onCopyQuote,
    this.onToggleFavourite,
    this.onAddToList,
    this.copyTooltip = "",
  });

  /// The direction to use as the main axis.
  final Axis direction;

  /// Whether user is authenticated.
  final bool authenticated;

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
      direction: direction,
      alignment: WrapAlignment.center,
      spacing: direction == Axis.vertical ? 0.0 : 12.0,
      runSpacing: direction == Axis.vertical ? 0.0 : 12.0,
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
        if (authenticated) ...[
          LikeButton(
            initialLiked: quote.starred,
            tooltip: quote.starred
                ? "quote.unlike.name".tr()
                : "quote.like.name".tr(),
          ),
          IconButton(
            color: iconColor,
            onPressed: onAddToList,
            icon: const Icon(TablerIcons.playlist_add),
            tooltip: "list.add.to".plural(1),
          ),
        ],
      ],
    );
  }
}
