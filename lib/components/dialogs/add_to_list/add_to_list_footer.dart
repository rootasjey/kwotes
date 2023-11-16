import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote_list.dart";

class AddToListFooter extends StatelessWidget {
  /// Footer component for [AddToListDialog] parent component.
  const AddToListFooter({
    super.key,
    this.asBottomSheet = false,
    this.elevation = 0.0,
    this.pageState = EnumPageState.idle,
    this.onValidate,
    this.showCreationInputs,
    this.selectedLists = const [],
  });

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Elevation of the widget.
  final double elevation;

  /// Page's state.
  final EnumPageState pageState;

  /// Trigger when the user tap on validation button
  final void Function(List<QuoteList> selectedLists)? onValidate;

  /// Callback fired to show creation inputs.
  final void Function()? showCreationInputs;

  /// List of quote lists.
  final List<QuoteList> selectedLists;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ColoredTextButton(
                  textAlign: TextAlign.center,
                  style: TextButton.styleFrom(
                    backgroundColor: selectedLists.isEmpty
                        ? Theme.of(context).scaffoldBackgroundColor
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 8.0,
                  ),
                  tooltip: selectedLists.isEmpty ? "list.add.hint".tr() : "",
                  onPressed: selectedLists.isEmpty
                      ? null
                      : () => onValidate?.call(selectedLists),
                  textValue: "${"list.add.to".plural(selectedLists.length)} "
                      "(${selectedLists.length})",
                ),
              ),
            ),
            CircleButton(
              icon: const Icon(TablerIcons.playlist_add),
              onTap: pageState == EnumPageState.loading
                  ? null
                  : showCreationInputs,
            ),
          ],
        ),
      ),
    );
  }
}