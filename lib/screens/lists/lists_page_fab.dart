import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:unicons/unicons.dart";

class ListsPageFab extends StatelessWidget {
  const ListsPageFab({
    super.key,
    this.fabActive = false,
    this.isMobileSize = false,
    this.showCreate = false,
    this.accentColor = Colors.amber,
    this.onToggleCreate,
  });

  final bool fabActive;
  final bool isMobileSize;
  final bool showCreate;
  final Color accentColor;
  final void Function()? onToggleCreate;

  @override
  Widget build(BuildContext context) {
    if (isMobileSize) {
      return FloatingActionButton(
        onPressed: fabActive ? onToggleCreate : null,
        splashColor: Colors.white,
        foregroundColor:
            accentColor.computeLuminance() > 0.4 ? Colors.black : Colors.white,
        backgroundColor: accentColor,
        tooltip:
            showCreate ? "list.create.close".tr() : "list.create.name".tr(),
        child: showCreate
            ? const Icon(UniconsLine.times)
            : const Icon(UniconsLine.plus),
      );
    }

    return FloatingActionButton.extended(
      onPressed: fabActive ? onToggleCreate : null,
      splashColor: Colors.white,
      foregroundColor:
          accentColor.computeLuminance() > 0.4 ? Colors.black : Colors.white,
      backgroundColor: accentColor,
      label: showCreate
          ? Text("list.create.close".tr())
          : Text("list.create.name".tr()),
      icon: showCreate
          ? const Icon(UniconsLine.times)
          : const Icon(UniconsLine.plus),
    );
  }
}
