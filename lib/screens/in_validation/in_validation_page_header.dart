import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/published/header_filter.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

/// In validation quotes page header.
class InValidationPageHeader extends StatelessWidget {
  const InValidationPageHeader({
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
    this.onTapTitle,
  });

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

  /// Callback fired when the title is tapped.
  final void Function()? onTapTitle;

  @override
  Widget build(BuildContext context) {
    final Color chipBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color chipBorderColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3) ??
            Colors.transparent;

    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onTapTitle?.call(),
            child: Hero(
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
                      fontSize: getFontSize(),
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
          ),
          AnimatedSize(
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              height: show ? null : 0.0,
              width: show ? null : 0.0,
              child: Opacity(
                opacity: show ? 1.0 : 0.0,
                child: HeaderFilter(
                  direction: isMobileSize ? Axis.vertical : Axis.horizontal,
                  chipBackgroundColor: chipBackgroundColor,
                  chipBorderColor: chipBorderColor,
                  chipSelectedColor: selectedColor,
                  iconColor: iconColor,
                  selectedOwnership: selectedOwnership,
                  onSelectedOwnership: onSelectedOwnership,
                  onSelectLanguage: onSelectLanguage,
                  selectedLanguage: selectedLanguage,
                  showAllLanguage: showAllLanguagesChip,
                  showAllOwnership: showAllOwnership,
                  show: show,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get title font size.
  double getFontSize() {
    if (isMobileSize) {
      return show ? 36.0 : 74.0;
    }

    return 124.0;
  }
}
