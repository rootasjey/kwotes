import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class SearchResultMeta extends StatelessWidget {
  const SearchResultMeta({
    super.key,
    this.isMobileSize = false,
    this.show = true,
    this.padding = EdgeInsets.zero,
    this.pageState,
    this.foregroundColor,
    this.resultCount = 0,
    this.onClearInput,
  });

  /// True if this is a mobile size.
  /// Used to determine the size of the search input.
  final bool isMobileSize;

  /// Decide whether to show this widget.
  final bool show;

  /// Text color.
  final Color? foregroundColor;

  /// Padding of this widget.
  final EdgeInsets padding;

  /// Page's state (e.g. searching, idle, ...).
  final EnumPageState? pageState;

  /// Search result count.
  final int resultCount;

  /// Callback fired when clear button is pressed.
  final void Function()? onClearInput;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    final String textValue = pageState == EnumPageState.searching ||
            pageState == EnumPageState.loading
        ? "search.ing".tr()
        : "• ${"search.result_count".plural(resultCount)} •";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          textValue,
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              color: foregroundColor?.withOpacity(0.6),
            ),
          ),
        ),
        IconButton(
          onPressed: onClearInput,
          tooltip: "search.clear".tr(),
          color: foregroundColor?.withOpacity(0.6),
          icon: const Icon(TablerIcons.square_rounded_x),
        ),
      ],
    );
  }
}
