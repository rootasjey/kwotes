import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
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
    final bool quoteSelected = categorySelected == EnumSearchCategory.quotes;
    final bool authorSelected = categorySelected == EnumSearchCategory.authors;
    final bool referenceSelected =
        categorySelected == EnumSearchCategory.references;

    const FontWeight selectedWeight = FontWeight.w500;

    return Padding(
        padding: margin,
        child: Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          alignment: WrapAlignment.start,
          children: [
            FilterChip(
              showCheckmark: false,
              selected: quoteSelected,
              elevation: quoteSelected ? 2.0 : 0.0,
              selectedColor: Constants.colors.quotes,
              onSelected: (bool _) => onSelectCategory?.call(
                EnumSearchCategory.quotes,
              ),
              shape: const StadiumBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: getForegroundColor(
                    selected: quoteSelected,
                    defaultColor: defaultColor,
                    selectedColor: Constants.colors.quotes,
                  ),
                  fontWeight: quoteSelected ? selectedWeight : null,
                ),
              ),
              label: Text("quote.names".tr()),
            ),
            FilterChip(
              showCheckmark: false,
              selected: authorSelected,
              elevation: authorSelected ? 2.0 : 0.0,
              selectedColor: Constants.colors.secondary,
              onSelected: (bool _) => onSelectCategory?.call(
                EnumSearchCategory.authors,
              ),
              shape: const StadiumBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              label: Text("author.names".tr()),
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: getForegroundColor(
                    selected: authorSelected,
                    defaultColor: defaultColor,
                    selectedColor: Constants.colors.authors,
                  ),
                  fontWeight: authorSelected ? selectedWeight : null,
                ),
              ),
            ),
            FilterChip(
              showCheckmark: false,
              selected: referenceSelected,
              elevation: referenceSelected ? 2.0 : 0.0,
              selectedColor: Constants.colors.references,
              onSelected: (bool _) =>
                  onSelectCategory?.call(EnumSearchCategory.references),
              shape: const StadiumBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              label: Text("reference.names".tr()),
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: getForegroundColor(
                    selected: referenceSelected,
                    defaultColor: defaultColor,
                    selectedColor: Constants.colors.references,
                  ),
                  fontWeight: referenceSelected ? selectedWeight : null,
                ),
              ),
            ),
          ],
        ));
  }

  /// Get the foreground color based on the selected state.
  Color? getForegroundColor({
    bool selected = false,
    Color? defaultColor,
    Color selectedColor = Colors.black,
  }) {
    if (!selected) {
      return defaultColor;
    }

    return selectedColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
  }
}
