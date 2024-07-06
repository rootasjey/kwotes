import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_search_category.dart";

class ChipCategorySelector extends StatelessWidget {
  /// A widget to select a search type (e.g. quote, author, reference).
  const ChipCategorySelector({
    super.key,
    required this.categorySelected,
    this.onSelectCategory,
    this.margin = EdgeInsets.zero,
    this.isDark = false,
  });

  /// Whether dark theme is active.
  final bool isDark;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Selected search category.
  final EnumSearchCategory categorySelected;

  /// Callback fired when a different search category is selected (e.g. author).
  final void Function(EnumSearchCategory searchEntity)? onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final Color? defaultColor = Theme.of(context).textTheme.bodyMedium?.color;
    const FontWeight selectedWeight = FontWeight.w500;

    return Container(
      height: 60.0,
      padding: margin,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          EnumSearchCategory.quotes,
          EnumSearchCategory.authors,
          EnumSearchCategory.references,
        ].map((EnumSearchCategory category) {
          final bool selected = category == categorySelected;
          final Color selectedColor = getSelectedColor();
          final Color? foregroundColor = getForegroundColor(
            selected: selected,
            defaultColor: defaultColor,
            selectedColor: selectedColor,
          );

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              showCheckmark: false,
              selected: selected,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelPadding: const EdgeInsets.only(
                right: 12.0,
              ),
              selectedColor: selectedColor,
              onSelected: (bool _) => onSelectCategory?.call(category),
              shape: StadiumBorder(
                side: BorderSide(
                  color: getBackgroundColor(category),
                ),
              ),
              avatar: CircleAvatar(
                foregroundColor: foregroundColor,
                backgroundColor: Colors.transparent,
                child: Icon(getIconData(category), size: 16.0),
              ),
              label: Text("search.chip.${category.name}".tr()),
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: foregroundColor,
                  fontWeight: selected ? selectedWeight : null,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Get the foreground color based on the selected state.
  Color? getForegroundColor({
    bool selected = false,
    Color? defaultColor,
    Color selectedColor = Colors.black,
  }) {
    if (!selected || isDark) {
      return defaultColor;
    }

    return selectedColor.computeLuminance() < 0.4 ? Colors.white : Colors.black;
  }

  Color getSelectedColor() {
    switch (categorySelected) {
      case EnumSearchCategory.quotes:
        return Constants.colors.quotes.withOpacity(0.2);
      case EnumSearchCategory.authors:
        return Constants.colors.authors.withOpacity(0.2);
      case EnumSearchCategory.references:
        return Constants.colors.references.withOpacity(0.2);
    }
  }

  Color getBackgroundColor(EnumSearchCategory category) {
    switch (category) {
      case EnumSearchCategory.quotes:
        return Constants.colors.quotes.withOpacity(0.2);
      case EnumSearchCategory.authors:
        return Constants.colors.authors.withOpacity(0.2);
      case EnumSearchCategory.references:
        return Constants.colors.references.withOpacity(0.2);
    }
  }

  IconData? getIconData(EnumSearchCategory category) {
    switch (category) {
      case EnumSearchCategory.quotes:
        return TablerIcons.quote;
      case EnumSearchCategory.authors:
        return TablerIcons.users;
      case EnumSearchCategory.references:
        return TablerIcons.books;
    }
  }
}
