import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/published/header_filter.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

/// Draft quotes page header.
class DraftsPageHeader extends StatelessWidget {
  const DraftsPageHeader({
    super.key,
    this.isMobileSize = false,
    this.show = true,
    this.selectedColor = Colors.amber,
    this.selectedLanguage = EnumLanguageSelection.all,
    this.onSelectLanguage,
    this.onTapTitle,
  });

  /// Adapt user interface to tiny screens if true.
  final bool isMobileSize;

  /// Display this widget if true.
  final bool show;

  /// Color of selected widgets.
  final Color selectedColor;

  /// Current selected language to fetch published quotes.
  final EnumLanguageSelection selectedLanguage;

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
              tag: "drafts",
              child: Material(
                color: Colors.transparent,
                child: Text.rich(
                  TextSpan(text: "drafts.name".tr(), children: [
                    TextSpan(
                      text: ".",
                      style: TextStyle(
                        color: Constants.colors.drafts,
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
                  showOwnershipSelector: false,
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

  /// Get title font size.
  double getFontSize() {
    if (isMobileSize) {
      return show ? 36.0 : 74.0;
    }

    return 124.0;
  }
}
