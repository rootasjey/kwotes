import "package:flutter/material.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/globals/utils.dart";

class MenuNavigationItem extends StatelessWidget {
  const MenuNavigationItem({
    super.key,
    required this.index,
    required this.icon,
    required this.selected,
    this.selectedColor,
    this.onTap,
    this.tooltip,
    this.label = "",
  });

  /// Index of the item. Must be unique.
  final int index;

  /// Whether the item is selected.
  final bool selected;

  /// Selected item color.
  final Color? selectedColor;

  /// Icon.
  final Widget icon;

  /// On tap callback with item's index.
  final Function(int index)? onTap;

  /// Tooltip displayed when the item is not selected.
  final String? tooltip;

  /// Text label.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        JustTheTooltip(
          tailLength: 10.0,
          preferredDirection: AxisDirection.up,
          waitDuration: const Duration(seconds: 1),
          content: Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tooltip ?? "",
              style: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          child: IconButton(
            color: selected ? selectedColor : null,
            isSelected: selected,
            onPressed: () => onTap?.call(index),
            icon: icon,
          ),
        ),
        if (selected && label.isNotEmpty)
          Text(
            label,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                color: selected ? selectedColor : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
