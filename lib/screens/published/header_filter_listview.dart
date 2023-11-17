import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/language_filter_data.dart";

class HeaderFilterListView extends StatelessWidget {
  const HeaderFilterListView({
    super.key,
    this.show = true,
    this.showAllLanguage = true,
    this.showLanguageSelector = true,
    this.showOwnershipSelector = true,
    this.useSliver = false,
    this.margin = EdgeInsets.zero,
    this.chipBackgroundColor,
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

  /// Show language selector if true.
  /// Default to true.
  final bool showLanguageSelector;

  /// Wrap this widget in a [SliverToBoxAdapter] if true.
  /// Default to false.
  final bool useSliver;

  /// Show ownership selector if true.
  /// Default to true.
  final bool showOwnershipSelector;

  /// Background color of the filter chips.
  final Color? chipBackgroundColor;

  /// Border color of the filter chips.
  final Color chipBorderColor;

  /// Background selected color of the filter chips.
  final Color chipSelectedColor;

  /// Icon color of the filter chips.
  final Color? iconColor;

  /// Space around this widget.
  final EdgeInsets margin;

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
    final List<Widget> ownershipChips = [];
    if (showOwnershipSelector) {
      ownershipChips.addAll([
        FilterChip(
          label: Text("quote.owned.name".tr()),
          tooltip: "quote.owned.description".tr(),
          backgroundColor: chipBackgroundColor,
          selectedColor: chipSelectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: chipBorderColor),
          ),
          onSelected: (bool _) =>
              onSelectedOwnership?.call(EnumDataOwnership.owned),
          selected: selectedOwnership == EnumDataOwnership.owned,
        ),
        FilterChip(
          label: Text("quote.all.name".tr()),
          tooltip: "quote.all.description".tr(),
          backgroundColor: chipBackgroundColor,
          selectedColor: chipSelectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: chipBorderColor),
          ),
          onSelected: (bool _) =>
              onSelectedOwnership?.call(EnumDataOwnership.all),
          selected: selectedOwnership == EnumDataOwnership.all,
        ),
        if (showLanguageSelector)
          const SizedBox(
            height: 28.0,
            child: VerticalDivider(thickness: 2.0),
          ),
      ]);
    }

    // final Color? maybeChipBackgroundColor = chipBackgroundColor;
    // TextStyle? labelStyle = const TextStyle(color: Colors.white);
    // if (maybeChipBackgroundColor != null &&
    //     maybeChipBackgroundColor.computeLuminance() > 0.5) {
    //   labelStyle = const TextStyle(color: Colors.black);
    // }

    final List<Widget> languageChips = [];
    if (showLanguageSelector) {
      languageChips.addAll(
        [
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
        ].map(
          (LanguageFilterData data) {
            final bool selected = selectedLanguage == data.language;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: data.labelString.isEmpty
                    ? Icon(data.iconData, color: iconColor)
                    : Text(data.labelString),
                tooltip: data.tooltipString,
                labelStyle: selected
                    ? const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      )
                    : null,
                backgroundColor: chipBackgroundColor,
                selectedColor: chipSelectedColor,
                checkmarkColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(color: chipBorderColor),
                ),
                onSelected: (bool _) => onSelectLanguage?.call(data.language),
                selected: selected,
              ),
            );
          },
        ).toList(),
      );
    }

    final List<Widget> children = [
      ...ownershipChips,
      ...languageChips,
    ];

    final Widget mainWidget = SizedBox(
      height: 42.0,
      child: ListView.separated(
        shrinkWrap: true,
        padding: margin,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return children[index];
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            width: 8.0,
          );
        },
        itemCount: children.length,
      ),
    );

    if (!useSliver) {
      return mainWidget;
    }

    return SliverToBoxAdapter(
      child: mainWidget,
    );
  }
}
