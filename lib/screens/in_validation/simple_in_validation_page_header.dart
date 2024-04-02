import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

/// In validation quotes page header.
class SimpleInValidationPageHeader extends StatelessWidget {
  const SimpleInValidationPageHeader({
    super.key,
    this.isMobileSize = false,
    this.show = false,
    this.showAllLanguagesChip = false,
    this.showAllOwnership = false,
    this.selectedColor = Colors.amber,
    this.selectedOwnership = EnumDataOwnership.owned,
    this.selectedLanguage = EnumLanguageSelection.all,
    this.onSelectedOwnership,
    this.onSelectLanguage,
    this.onTapFilter,
    this.canManageQuotes = false,
  });

  /// True if the current user can manage quotes.
  final bool canManageQuotes;

  /// Adpat UI for mobile size if true.
  final bool isMobileSize;

  /// Display this widget if true.
  final bool show;

  /// Display all languages chip if true.
  final bool showAllLanguagesChip;

  /// Display all ownership chip if true.
  final bool showAllOwnership;

  /// Color of selected widgets.
  final Color selectedColor;

  /// Selected quotes ownership (owned | all).
  final EnumDataOwnership selectedOwnership;

  /// Current selected language to fetch published quotes.
  final EnumLanguageSelection selectedLanguage;

  /// Callback fired when a quote filter is selected (owned | all).
  final void Function(EnumDataOwnership ownership)? onSelectedOwnership;

  /// Callback fired when a language is selected.
  final void Function(EnumLanguageSelection language)? onSelectLanguage;

  /// Callback fired when the filter is tapped.
  final void Function(bool canManageQuotes)? onTapFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleButton(
          onTap: () => onTapFilter?.call(canManageQuotes),
          radius: 14.0,
          margin: const EdgeInsets.only(right: 12.0),
          icon: const Icon(TablerIcons.filter, size: 14.0),
        ),
        Hero(
          tag: "in_validation",
          child: Material(
            color: Colors.transparent,
            child: Text.rich(
              TextSpan(text: "in_validation.name".tr(), children: [
                TextSpan(
                  text: ".",
                  style: TextStyle(
                    color: Constants.colors.inValidation,
                  ),
                ),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Utils.calligraphy.title(
                textStyle: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
