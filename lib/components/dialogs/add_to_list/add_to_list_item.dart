import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote_list.dart";

class AddToListItem extends StatelessWidget {
  const AddToListItem({
    super.key,
    required this.quoteList,
    this.selected = false,
    this.selectedColor,
    this.onTap,
    this.onLongPress,
  });

  /// True if the list is selected.
  final bool selected;

  /// Selected list color.
  final Color? selectedColor;

  /// Quote list data.
  final QuoteList quoteList;

  /// Callback fired when a quote list is tapped.
  final void Function(QuoteList quoteList)? onTap;

  /// Callback fired when a quote list is long pressed.
  final void Function(QuoteList quoteList)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextButton(
        onPressed: onTap != null ? () => onTap?.call(quoteList) : null,
        onLongPress:
            onLongPress != null ? () => onLongPress?.call(quoteList) : null,
        style: TextButton.styleFrom(
          alignment: Alignment.topLeft,
          foregroundColor: selectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          children: [
            Text(
              quoteList.name,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: selected
                      ? null
                      : Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.8),
                  fontSize: 34.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            const Spacer(),
            if (selected) const Icon(TablerIcons.check),
          ],
        ),
      ),
    );
  }
}
