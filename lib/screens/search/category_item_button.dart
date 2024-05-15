import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_tooltip.dart";
import "package:kwotes/components/dot_indicator.dart";
import "package:kwotes/types/enums/enum_indicator_type.dart";
import "package:kwotes/types/enums/enum_search_category.dart";

class CategoryItemButton extends StatelessWidget {
  /// A button for displaying a search category (e.g. quote, author, reference).
  const CategoryItemButton({
    super.key,
    required this.category,
    this.selectedColor = Colors.pink,
    this.iconData = TablerIcons.message_circle_2,
    this.selected = false,
    this.defaultColor,
    this.onSelectEntity,
    this.tooltip,
    this.indicatorType = IndicatorType.dot,
  });

  /// True if this entity is selected.
  final bool selected;

  /// Color of the icon and dot when selected.
  final Color selectedColor;

  /// Default icon's color.
  final Color? defaultColor;

  /// Search category of this widget.
  final EnumSearchCategory category;

  /// Icon data of this widget.
  final IconData iconData;

  /// Indicator type of this widget (e.g. dot, pill).
  final IndicatorType indicatorType;

  /// Callback fired when this button is tapped.
  final void Function(EnumSearchCategory searchEntity)? onSelectEntity;

  /// Tooltip of this button.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: BetterTooltip(
        tooltipString: tooltip ?? "",
        child: Column(
          children: [
            IconButton(
              isSelected: selected,
              onPressed: () => onSelectEntity?.call(category),
              color: selected ? selectedColor : defaultColor,
              icon: Icon(iconData),
            ),
            if (indicatorType == IndicatorType.pill)
              Container(
                width: 16.0,
                height: 4.0,
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: selected ? selectedColor : null,
                ),
              ),
            if (indicatorType == IndicatorType.dot)
              DotIndicator(
                color: selected ? selectedColor : Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }
}
