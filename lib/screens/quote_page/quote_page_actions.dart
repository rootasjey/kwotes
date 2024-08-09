import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/like_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote.dart";

class QuotePageActions extends StatelessWidget {
  /// Quote page actions.
  const QuotePageActions({
    super.key,
    required this.copyIcon,
    required this.quote,
    this.direction = Axis.vertical,
    this.authenticated = false,
    this.minimal = false,
    this.onAddToList,
    this.onCopyQuote,
    this.onNavigateBack,
    this.onShareQuote,
    this.onToggleFavourite,
    this.copyTooltip = "",
  });

  /// The direction to use as the main axis.
  final Axis direction;

  /// Whether user is authenticated.
  final bool authenticated;

  /// Hide duplicated actions (e.g. [close], [copy]) if this is true.
  final bool minimal;

  /// Callback fired to add quote to list.
  final Function()? onAddToList;

  /// Callback fired to copy quote's content.
  final Function(Quote quote)? onCopyQuote;

  /// Callback fired to return to the previous page.
  final Function()? onNavigateBack;

  /// Callback fired to share a quote.
  final Function()? onShareQuote;

  /// Callback fired to toggle quote's favourite status.
  final Function()? onToggleFavourite;

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

    // It seems that the button is not fully centered
    // on android. This fixes it.
    final EdgeInsets likeButtonMargin = Utils.graphic.isMobile()
        ? const EdgeInsets.only(top: 8.0)
        : const EdgeInsets.only(top: 2.0);

    return Wrap(
      direction: direction,
      alignment: WrapAlignment.center,
      spacing: direction == Axis.vertical ? 0.0 : 12.0,
      runSpacing: direction == Axis.vertical ? 0.0 : 12.0,
      children: [
        if (!minimal)
          IconButton(
            color: iconColor,
            onPressed: onNavigateBack,
            icon: const Icon(TablerIcons.x),
          ),
        if (!minimal)
          IconButton(
            color: iconColor,
            onPressed: () => onCopyQuote?.call(quote),
            icon: Icon(copyIcon),
            tooltip: copyTooltip,
          ),
        IconButton(
          color: iconColor,
          onPressed: onShareQuote,
          icon: const Icon(TablerIcons.share_2),
          tooltip: "quote.share.name".tr(),
        ),
        LikeButton(
          color: iconColor,
          onPressed: onToggleFavourite,
          margin: likeButtonMargin,
          initialLiked: quote.starred,
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
