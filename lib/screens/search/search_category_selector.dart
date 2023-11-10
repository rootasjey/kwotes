import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/screens/search/category_item_button.dart";
import "package:kwotes/types/enums/enum_indicator_type.dart";
import "package:kwotes/types/enums/enum_search_category.dart";
import "package:unicons/unicons.dart";

class SearchCategorySelector extends StatelessWidget {
  /// A widget to select a search type (e.g. quote, author, reference).
  const SearchCategorySelector({
    super.key,
    required this.categorySelected,
    required this.onSelectCategory,
  });

  /// Selected search category.
  final EnumSearchCategory categorySelected;

  /// Callback fired when a different search category is selected (e.g. author).
  final void Function(EnumSearchCategory searchEntity) onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final Color? defaultColor = Theme.of(context).textTheme.bodyMedium?.color;
    final bool quoteSelected = categorySelected == EnumSearchCategory.quote;
    final bool authorSelected = categorySelected == EnumSearchCategory.author;
    final bool referenceSelected =
        categorySelected == EnumSearchCategory.reference;

    return Material(
      elevation: 8.0,
      color: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(color: getSelectedColor(categorySelected), width: 1.0),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 0.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryItemButton(
              defaultColor: defaultColor,
              category: EnumSearchCategory.quote,
              iconData: UniconsLine.chat,
              indicatorType: IndicatorType.pill,
              onSelectEntity: onSelectCategory,
              selected: quoteSelected,
              selectedColor: Colors.pink,
              tooltip: "search.quotes".tr(),
            ),
            CategoryItemButton(
              defaultColor: defaultColor,
              category: EnumSearchCategory.author,
              iconData: TablerIcons.users,
              indicatorType: IndicatorType.pill,
              onSelectEntity: onSelectCategory,
              selected: authorSelected,
              selectedColor: Colors.amber,
              tooltip: "search.authors".tr(),
            ),
            CategoryItemButton(
              defaultColor: defaultColor,
              category: EnumSearchCategory.reference,
              iconData: UniconsLine.book_alt,
              indicatorType: IndicatorType.pill,
              onSelectEntity: onSelectCategory,
              selected: referenceSelected,
              selectedColor: Colors.blue,
              tooltip: "search.references".tr(),
            ),
          ],
        ),
      ),
    );
  }

  Color getSelectedColor(EnumSearchCategory categorySelected) {
    switch (categorySelected) {
      case EnumSearchCategory.quote:
        return Colors.pink;
      case EnumSearchCategory.author:
        return Colors.amber;
      case EnumSearchCategory.reference:
        return Colors.blue;
      default:
        return Colors.transparent;
    }
  }
}
