import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:unicons/unicons.dart";

class ListsPageFab extends StatelessWidget {
  const ListsPageFab({
    super.key,
    this.isActive = false,
    this.isMobileSize = false,
    this.showCreate = false,
    this.backgroundColor = Colors.amber,
    this.onPressed,
    this.splashColor = Colors.white,
  });

  /// If false, this Floating Action Button will not have [onPressed] callback.
  final bool isActive;

  /// If true, this Floating Action Button will only display an icon.
  /// Otherwise, it will display both icon & text.
  final bool isMobileSize;

  /// Either show create or close button.
  final bool showCreate;

  /// Button background color.
  final Color backgroundColor;

  /// A random color to pain the splash button.
  final Color splashColor;

  /// Callback fired when this button is tapped.
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isMobileSize) {
      return FloatingActionButton(
        onPressed: isActive ? onPressed : null,
        splashColor: splashColor,
        foregroundColor: backgroundColor.computeLuminance() > 0.4
            ? Colors.black
            : Colors.white,
        backgroundColor: backgroundColor,
        tooltip:
            showCreate ? "list.create.close".tr() : "list.create.name".tr(),
        child: showCreate
            ? const Icon(UniconsLine.times)
            : const Icon(UniconsLine.plus),
      );
    }

    final TextStyle textStyle = Utils.calligraphy.body(
        textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
    ));

    return FloatingActionButton.extended(
      onPressed: isActive ? onPressed : null,
      splashColor: splashColor,
      foregroundColor: backgroundColor.computeLuminance() > 0.4
          ? Colors.black
          : Colors.white,
      backgroundColor: backgroundColor,
      label: showCreate
          ? Text("list.create.close".tr(), style: textStyle)
          : Text("list.create.name".tr(), style: textStyle),
      icon: showCreate
          ? const Icon(UniconsLine.times)
          : const Icon(UniconsLine.plus),
    );
  }
}
