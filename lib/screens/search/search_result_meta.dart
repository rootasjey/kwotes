import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
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
    final String textValue = pageState == EnumPageState.searching ||
            pageState == EnumPageState.loading
        ? "search.ing".tr()
        : "search.result_count".plural(resultCount);

    return Opacity(
      opacity: show ? 1.0 : 0.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              textValue,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  color: foregroundColor?.withOpacity(0.6),
                ),
              ),
            ),
            if (onClearInput != null)
              JustTheTooltip(
                tailLength: 10.0,
                preferredDirection: AxisDirection.down,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "search.clear".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                child: IconButton(
                  onPressed: onClearInput,
                  color: foregroundColor?.withOpacity(0.6),
                  icon: const Icon(TablerIcons.square_rounded_x),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
