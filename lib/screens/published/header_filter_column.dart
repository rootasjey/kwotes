import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/language_filter_data.dart";
import "package:kwotes/types/ownership_data.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";

class HeaderFilterColumn extends StatelessWidget {
  /// A vertical component to filter page data with selector
  /// (e.g. language, ownership).
  const HeaderFilterColumn({
    super.key,
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

  /// Show this widget if true.
  final bool show;

  /// Show "all language" selector if true.
  /// Default to true.
  final bool showAllLanguage;

  /// Show "all ownership" chip selector if true.
  /// Default to false.
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

  /// Callback fired when a quote filter is selected (owned | all).
  final void Function(EnumDataOwnership ownership)? onSelectedOwnership;

  /// Callback fired when a language is selected.
  final void Function(EnumLanguageSelection language)? onSelectLanguage;

  /// Current selected language to fetch published quotes.
  final EnumLanguageSelection selectedLanguage;

  @override
  Widget build(BuildContext context) {
    const double boxHeight = 42.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onSelectedOwnership != null)
          Text(
            "ownership.name".tr().toUpperCase(),
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.4),
              ),
            ),
          ),
        if (onSelectedOwnership != null)
          SizedBox(
            height: boxHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                if (showAllOwnership)
                  OwnershipData(
                    ownership: EnumDataOwnership.all,
                    labelString: "quote.all.name".tr(),
                    tooltipString: "quote.all.description".tr(),
                  ),
                OwnershipData(
                  ownership: EnumDataOwnership.owned,
                  labelString: "quote.owned.name".tr(),
                  tooltipString: "quote.owned.description".tr(),
                ),
              ]
                  .map(
                    (OwnershipData data) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        checkmarkColor: iconColor,
                        label: Text(data.labelString),
                        tooltip: data.tooltipString,
                        backgroundColor: chipBackgroundColor,
                        selectedColor: chipSelectedColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(color: chipBorderColor),
                        ),
                        onSelected: (bool _) =>
                            onSelectedOwnership?.call(data.ownership),
                        selected: selectedOwnership == data.ownership,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        if (onSelectedOwnership != null && onSelectedOwnership != null)
          const SizedBox(height: 16.0),
        if (onSelectLanguage != null)
          Text(
            "language.name".tr().toUpperCase(),
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.4),
              ),
            ),
          ),
        if (onSelectLanguage != null)
          SizedBox(
            height: boxHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                if (showAllLanguage)
                  LanguageFilterData(
                    labelString: "",
                    tooltipString: "language.all".tr(),
                    language: EnumLanguageSelection.all,
                    iconData: TablerIcons.world_longitude,
                  ),
                ...Utils.linguistic.available().map(
                      (locale) => LanguageFilterData(
                        labelString: "language.locale.${locale.name}".tr(),
                        tooltipString: "",
                        language: locale,
                      ),
                    ),
              ]
                  .map(
                    (LanguageFilterData data) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        checkmarkColor: iconColor,
                        label: data.labelString.isEmpty
                            ? Icon(data.iconData, color: iconColor, size: 20.0)
                            : Text(data.labelString),
                        tooltip: data.tooltipString,
                        backgroundColor: chipBackgroundColor,
                        selectedColor: chipSelectedColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(color: chipBorderColor),
                        ),
                        onSelected: (bool _) =>
                            onSelectLanguage?.call(data.language),
                        selected: selectedLanguage == data.language,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
