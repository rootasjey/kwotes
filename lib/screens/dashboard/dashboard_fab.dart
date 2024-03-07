import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class DashboardFab extends StatelessWidget {
  /// Floating Action Button of the Dashboard page.
  const DashboardFab({
    super.key,
    required this.backgroundColor,
    this.isMobileSize = false,
    this.splashColor = Colors.white,
    this.onGoToAddQuotePage,
  });

  /// If true, this Floating Action Button will only display an icon.
  /// Otherwise, it will display both icon & text.
  final bool isMobileSize;

  /// A random color to pain the background button.
  final Color backgroundColor;

  /// A random color to pain the background button.
  final Color? splashColor;

  /// Callback fired when this button is tapped.
  final void Function(BuildContext context)? onGoToAddQuotePage;

  @override
  Widget build(BuildContext context) {
    if (isMobileSize) {
      return FloatingActionButton(
        onPressed: () => onGoToAddQuotePage?.call(context),
        tooltip: "quote.add.a".tr(),
        splashColor: splashColor,
        backgroundColor: backgroundColor,
        foregroundColor: backgroundColor.computeLuminance() > 0.4
            ? Colors.black
            : Colors.white,
        child: const Icon(TablerIcons.message_2_plus),
      );
    }

    return FloatingActionButton.extended(
      hoverElevation: 4.0,
      focusElevation: 0.0,
      highlightElevation: 0.0,
      splashColor: splashColor,
      onPressed: () => onGoToAddQuotePage?.call(context),
      backgroundColor: backgroundColor,
      icon: const Icon(TablerIcons.message_2_plus),
      foregroundColor: backgroundColor.computeLuminance() > 0.4
          ? Colors.black
          : Colors.white,
      label: Text(
        "quote.add.a".tr(),
        style: Utils.calligraphy.body(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
