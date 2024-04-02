import "package:flutter/material.dart";
import "package:kwotes/screens/published/header_filter_column.dart";
import "package:kwotes/screens/published/header_filter_wrap.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

class HeaderFilter extends StatelessWidget {
  /// A component to filter page data with selector (e.g. language, ownership).
  const HeaderFilter({
    super.key,
    this.direction = Axis.horizontal,
    this.show = true,
    this.showAllLanguage = true,
    this.showAllOwnership = false,
    this.chipBackgroundColor = Colors.white,
    this.chipBorderColor = Colors.transparent,
    this.chipSelectedColor = Colors.amber,
    this.iconColor,
    this.selectedOwnership,
    this.onSelectedOwnership,
    this.onSelectLanguage,
    this.selectedLanguage = EnumLanguageSelection.all,
  });

  /// Horizontal direction will display a [Wrap] with children
  /// separated with vertical [Divider] between each of them.
  /// Vertical direction will display a [Column]
  /// and is more suitable for mobile size screens.
  final Axis direction;

  /// Show this widget if true.
  final bool show;

  /// Show all language chip if true.
  final bool showAllLanguage;

  /// Show all ownership chip if true.
  final bool showAllOwnership;

  /// Background color of the filter chips.
  final Color chipBackgroundColor;

  /// Border color of the filter chips.
  final Color chipBorderColor;

  /// Background selected color of the filter chips.
  final Color chipSelectedColor;

  /// Icon color of the filter chips.
  final Color? iconColor;

  /// Selected quotes ownership (owned | all).
  final EnumDataOwnership? selectedOwnership;

  /// Current selected language to fetch published quotes.
  final EnumLanguageSelection selectedLanguage;

  /// Callback fired when a quote filter is selected (owned | all).
  final void Function(EnumDataOwnership ownership)? onSelectedOwnership;

  /// Callback fired when a language is selected.
  final void Function(EnumLanguageSelection language)? onSelectLanguage;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    if (direction == Axis.vertical) {
      return HeaderFilterColumn(
        chipBackgroundColor: chipBackgroundColor,
        chipBorderColor: chipBorderColor,
        chipSelectedColor: chipSelectedColor,
        iconColor: iconColor,
        selectedOwnership: selectedOwnership,
        onSelectedOwnership: onSelectedOwnership,
        onSelectLanguage: onSelectLanguage,
        selectedLanguage: selectedLanguage,
        showAllLanguage: showAllLanguage,
        showAllOwnership: showAllOwnership,
        show: show,
      );
    }

    return HeaderFilterWrap(
      chipBackgroundColor: chipBackgroundColor,
      chipBorderColor: chipBorderColor,
      chipSelectedColor: chipSelectedColor,
      iconColor: iconColor,
      selectedOwnership: selectedOwnership,
      onSelectedOwnership: onSelectedOwnership,
      onSelectLanguage: onSelectLanguage,
      selectedLanguage: selectedLanguage,
      showAllLanguage: showAllLanguage,
      showAllOwnership: showAllOwnership,
      show: show,
    );
  }
}
