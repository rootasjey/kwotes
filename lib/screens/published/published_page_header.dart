import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/published/header_filter.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

/// Published page header.
class PublishedPageHeader extends StatelessWidget {
  const PublishedPageHeader({
    super.key,
    required this.selectedLanguage,
    this.isMobileSize = false,
    this.show = true,
    this.selectedColor = Colors.amber,
    this.selectedOwnership = EnumDataOwnership.owned,
    this.onSelectedOwnership,
    this.onSelectLanguage,
    this.onTapTitle,
  });

  /// True if the page is mobile size.
  final bool isMobileSize;

  /// Display this widget if true.
  final bool show;

  /// Background color of the selected filter chip.
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
      padding: isMobileSize
          ? const EdgeInsets.only(left: 6.0, bottom: 24.0)
          : const EdgeInsets.only(left: 48.0, bottom: 42.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTapTitle,
            child: Hero(
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
                      fontSize: isMobileSize ? 42.0 : 74.0,
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
                  show: show,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
