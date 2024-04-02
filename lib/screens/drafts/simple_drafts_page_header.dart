import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

/// Draft quotes page header.
class SimpleDraftsPageHeader extends StatelessWidget {
  const SimpleDraftsPageHeader({
    super.key,
    this.isMobileSize = false,
    this.show = true,
    this.selectedColor = Colors.amber,
    this.selectedLanguage = EnumLanguageSelection.all,
    this.onSelectLanguage,
    this.onTapFilter,
  });

  /// Adapt user interface to tiny screens if true.
  final bool isMobileSize;

  /// Display this widget if true.
  final bool show;

  /// Color of selected widgets.
  final Color selectedColor;

  /// Current selected language to fetch published quotes.
  final EnumLanguageSelection selectedLanguage;

  /// Callback fired when the filter is tapped.
  final void Function()? onTapFilter;

  /// Callback fired when a language is selected.
  final void Function(EnumLanguageSelection language)? onSelectLanguage;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleButton(
          onTap: onTapFilter,
          radius: 14.0,
          margin: const EdgeInsets.only(right: 12.0),
          icon: const Icon(TablerIcons.filter, size: 14.0),
        ),
        Hero(
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
