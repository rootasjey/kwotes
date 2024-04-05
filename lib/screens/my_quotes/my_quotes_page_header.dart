import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/my_quotes_tab_data.dart";
import "package:kwotes/types/enums/enum_my_quotes_tab.dart";

/// Draft quotes page header.
class MyQuotesPageHeader extends StatelessWidget {
  const MyQuotesPageHeader({
    super.key,
    this.isMobileSize = false,
    this.show = true,
    this.selectedTab = EnumMyQuotesTab.drafts,
    this.onSelectTab,
    this.onTapTitle,
  });

  /// Adapt user interface to tiny screens if true.
  final bool isMobileSize;

  /// Display this widget if true.
  final bool show;

  /// Current selected language to fetch published quotes.
  final EnumMyQuotesTab selectedTab;

  /// Callback fired when a language is selected.
  final void Function(EnumMyQuotesTab newTab)? onSelectTab;

  /// Callback fired when the title is tapped.
  final void Function()? onTapTitle;

  @override
  Widget build(BuildContext context) {
    const Color chipBorderColor = Colors.transparent;
    final Color? iconColor = Theme.of(context).textTheme.bodyMedium?.color;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color chipBackgroundColor =
        isDark ? Colors.grey.shade800 : Colors.white30;

    final TextStyle labelStyle = Utils.calligraphy.body(
      textStyle: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: iconColor,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTapTitle,
          child: Hero(
            tag: "my_quotes",
            child: Material(
              color: Colors.transparent,
              child: Text.rich(
                TextSpan(text: "my_quotes.name".tr(), children: [
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
                    fontSize: 74.0,
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
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            MyQuotesTabData(
              textLabel: "drafts.name".tr(),
              tab: EnumMyQuotesTab.drafts,
              selectedColor: Constants.colors.drafts,
            ),
            MyQuotesTabData(
              textLabel: "in_validation.name".tr(),
              tab: EnumMyQuotesTab.inValidation,
              selectedColor: Constants.colors.inValidation,
            ),
            MyQuotesTabData(
              textLabel: "published.name".tr(),
              tab: EnumMyQuotesTab.published,
              selectedColor: Constants.colors.published,
            ),
          ].map(
            (MyQuotesTabData data) {
              final bool selected = data.tab == selectedTab;
              final Color selectedColor = getChipSelectedColor(data.tab);
              TextStyle selectedStyle = labelStyle;
              Color selectedForeground = Colors.white;

              if (selected) {
                selectedForeground = selectedColor.computeLuminance() < 0.5
                    ? Colors.white
                    : Colors.black;

                selectedStyle = selectedStyle.merge(
                  TextStyle(
                    color: selectedForeground,
                  ),
                );
              }

              return FilterChip(
                showCheckmark: false,
                labelStyle: selectedStyle,
                label: Text(data.textLabel),
                avatar: selected
                    ? Icon(
                        TablerIcons.filter,
                        color: selectedForeground,
                        size: 16.0,
                      )
                    : null,
                backgroundColor: chipBackgroundColor,
                selectedColor: selectedColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: const BorderSide(color: chipBorderColor),
                ),
                onSelected: (bool _) => onSelectTab?.call(data.tab),
                selected: selected,
                // selected: selectedOwnership == data.ownership,
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  getChipSelectedColor(EnumMyQuotesTab tab) {
    switch (tab) {
      case EnumMyQuotesTab.drafts:
        return Constants.colors.drafts;
      case EnumMyQuotesTab.inValidation:
        return Constants.colors.inValidation;
      case EnumMyQuotesTab.published:
        return Constants.colors.published;
    }
  }
}
