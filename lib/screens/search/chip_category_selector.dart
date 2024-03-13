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

    return Padding(
        padding: margin,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.start,
          children: [
            ActionChip(
              color: quoteSelected
                  ? MaterialStateProperty.all(Constants.colors.quotes)
                  : null,
              onPressed: () => onSelectCategory?.call(
                EnumSearchCategory.quotes,
              ),
              shape: const StadiumBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: quoteSelected ? Colors.black : defaultColor,
                  fontWeight: quoteSelected ? FontWeight.w600 : null,
                ),
              ),
              label: Text("quote.names".tr()),
            ),
            ActionChip(
              color: authorSelected
                  ? MaterialStateProperty.all(Constants.colors.authors)
                  : null,
              onPressed: () =>
                  onSelectCategory?.call(EnumSearchCategory.authors),
              shape: const StadiumBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              label: Text("author.names".tr()),
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontWeight: authorSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
            ActionChip(
              color: referenceSelected
                  ? MaterialStateProperty.all(Constants.colors.references)
                  : null,
              onPressed: () =>
                  onSelectCategory?.call(EnumSearchCategory.references),
              shape: const StadiumBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              label: Text("reference.names".tr()),
              labelStyle: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: referenceSelected ? Colors.black : defaultColor,
                  fontWeight: referenceSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
          ],
        ));
  }
}
