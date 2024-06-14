import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_tooltip.dart";
import "package:kwotes/globals/utils.dart";

class BigTextHeader extends StatelessWidget {
  /// Display a big colored text.
  /// Usually displayed at the top of a page.
  /// Most suitable for desktop sizes.
  const BigTextHeader({
    super.key,
    required this.titleValue,
    this.subtitleValue = "",
    this.show = true,
    this.accentColor,
  });

  /// Whether to show this widget.
  /// Display if true.
  final bool show;

  /// Accent color of some components in this widget.
  final Color? accentColor;

  /// The text to display.
  final String titleValue;

  /// The text to display below the title.
  final String subtitleValue;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BetterTooltip(
          tooltipString: "back".tr(),
          child: IconButton(
            onPressed: () => Utils.passage.deepBack(context),
            icon: const Icon(TablerIcons.arrow_left),
            style: IconButton.styleFrom(
              backgroundColor: accentColor?.withOpacity(0.1),
            ),
            padding: const EdgeInsets.only(bottom: 2.0),
          ),
        ),
        Text(
          titleValue,
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 84.0,
              fontWeight: FontWeight.w700,
              color: accentColor,
              height: 1.2,
            ),
          ),
        ),
        if (subtitleValue.isNotEmpty)
          Opacity(
            opacity: 0.6,
            child: Text(
              subtitleValue,
              style: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  // color: accentColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
