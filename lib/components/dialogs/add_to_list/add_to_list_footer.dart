import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote_list.dart";

class AddToListFooter extends StatelessWidget {
  /// Footer component for [AddToListDialog] parent component.
  const AddToListFooter({
    super.key,
    this.asBottomSheet = false,
    this.selectedColor,
    this.elevation = 0.0,
    this.pageState = EnumPageState.idle,
    this.onValidate,
    this.onCancelMultiselect,
    this.selectedLists = const [],
    this.show = false,
  });

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// If true, the widget will show button to validate addition.
  final bool show;

  /// Selected list color.
  final Color? selectedColor;

  /// Elevation of the widget.
  final double elevation;

  /// Page's state.
  final EnumPageState pageState;

  /// Trigger when the user tap on validation button
  final void Function(List<QuoteList> selectedLists)? onValidate;

  /// Callback fired to cancel multiselect.
  final void Function()? onCancelMultiselect;

  /// List of quote lists.
  final List<QuoteList> selectedLists;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Material(
      elevation: elevation,
      color: backgroundColor,
      child: Column(
        children: [
          Divider(
            height: 0.0,
            thickness: 2.0,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          Padding(
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: selectedLists.isEmpty
                            ? null
                            : () => onValidate?.call(selectedLists),
                        icon: const Icon(TablerIcons.checks, size: 18.0),
                        label: Text(
                          "${"list.add.to".plural(selectedLists.length)} "
                          "(${selectedLists.length})",
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Constants.colors.lists,
                          textStyle: Utils.calligraphy.body(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side: BorderSide(
                              color: Constants.colors.lists,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                CircleButton(
                  backgroundColor: backgroundColor,
                  tooltip: "back".tr(),
                  icon: Icon(
                    TablerIcons.arrow_back,
                    color: foregroundColor?.withOpacity(0.6),
                  ),
                  onTap: pageState == EnumPageState.loading
                      ? null
                      : onCancelMultiselect,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
