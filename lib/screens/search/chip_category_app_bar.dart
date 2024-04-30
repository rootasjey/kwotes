import "package:flutter/material.dart";
import "package:kwotes/screens/search/chip_category_selector.dart";
import "package:kwotes/types/enums/enum_search_category.dart";
import "package:sliver_tools/sliver_tools.dart";

class ChipCategoryAppBar extends StatelessWidget {
  const ChipCategoryAppBar({
    super.key,
    this.isDark = false,
    required this.categorySelected,
    this.onSelectCategory,
    this.margin = EdgeInsets.zero,
  });

  /// Adapt the UI to dark mode if true.
  final bool isDark;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Selected search category.
  final EnumSearchCategory categorySelected;

  /// Callback fired when a different search category is selected (e.g. author).
  final void Function(EnumSearchCategory searchEntity)? onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return SliverPinnedHeader(
      child: ChipCategorySelector(
        isDark: isDark,
        margin: margin,
        categorySelected: categorySelected,
        onSelectCategory: onSelectCategory,
      ),
    );
  }
}
