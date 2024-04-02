import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

/// Published page header.
class SimplePublishedPageHeader extends StatelessWidget {
  const SimplePublishedPageHeader({
    super.key,
    this.isMobileSize = false,
    this.show = true,
    this.canSeeOtherQuotes = false,
    this.showAllOwnership = true,
    this.selectedColor = Colors.amber,
    this.selectedOwnership = EnumDataOwnership.owned,
    this.onSelectedOwnership,
    this.onSelectLanguage,
    this.onTapFilter,
  });

  /// True if the current user can manage quotes.
  final bool canSeeOtherQuotes;

  /// True if the page is mobile size.
  final bool isMobileSize;

  /// Display this widget if true.
  final bool show;

  /// Display all ownership filter if true.
  final bool showAllOwnership;

  /// Background color of the selected filter chip.
  final Color selectedColor;

  /// Selected quotes ownership (owned | all).
  final EnumDataOwnership selectedOwnership;

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
          onTap: () => onTapFilter?.call(canSeeOtherQuotes),
          radius: 14.0,
          margin: const EdgeInsets.only(right: 12.0),
          icon: const Icon(TablerIcons.filter, size: 14.0),
        ),
        Hero(
          tag: "published",
          child: Material(
            color: Colors.transparent,
            child: Text.rich(
              TextSpan(text: "published.name".tr(), children: [
                TextSpan(
                  text: ".",
                  style: TextStyle(
                    color: Constants.colors.published,
                  ),
                ),
              ]),
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
