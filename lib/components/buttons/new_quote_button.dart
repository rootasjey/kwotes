import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_tooltip.dart";
import "package:kwotes/globals/utils.dart";

class NewQuoteButton extends StatelessWidget {
  const NewQuoteButton({
    super.key,
    this.isDark = false,
    this.foregroundColor,
    this.verticalButtonPadding = 8.0,
    this.onTapNewQuoteButton,
  });

  /// True if the theme is dark.
  final bool isDark;

  /// Foreground color.
  final Color? foregroundColor;

  /// Vertical button padding.
  final double verticalButtonPadding;

  /// Callback fired when new quote button is tapped.
  final void Function(BuildContext context)? onTapNewQuoteButton;

  @override
  Widget build(BuildContext context) {
    return BetterTooltip(
      tooltipString: "quote.new".tr(),
      child: TextButton.icon(
        onPressed: () => onTapNewQuoteButton?.call(context),
        style: TextButton.styleFrom(
          backgroundColor: isDark ? Colors.black : Colors.white,
          foregroundColor: foregroundColor,
          minimumSize: const Size(0.0, 0.0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.symmetric(
            vertical: verticalButtonPadding,
            horizontal: 24.0,
          ),
          shape: const StadiumBorder(),
        ),
        icon: const Icon(TablerIcons.plus, size: 16.0),
        label: Text(
          "quote.name".tr(),
          style: Utils.calligraphy.body(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
