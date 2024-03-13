import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

class QuoteLanguageSelector extends StatelessWidget {
  const QuoteLanguageSelector({
    super.key,
    required this.languageSelection,
    required this.autoDetectedLanguage,
    this.isDark = false,
    this.foregroundColor,
    this.onSelectLanguage,
  });

  /// Use dark mode if true.
  final bool isDark;

  /// Foreground color of the language selector.
  final Color? foregroundColor;

  /// Language selection.
  final EnumLanguageSelection languageSelection;

  /// Auto detected quote's language.
  final String autoDetectedLanguage;

  /// Callback fired when a language is selected.
  final void Function(EnumLanguageSelection languageSelection)?
      onSelectLanguage;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          trailingIcon: const Icon(TablerIcons.bolt, size: 14.0),
          onPressed: () {
            onSelectLanguage?.call(EnumLanguageSelection.autoDetect);
          },
          child: Text("language.locale.autoDetect".tr()),
        ),
        MenuItemButton(
          child: Text("language.locale.en".tr()),
          onPressed: () {
            onSelectLanguage?.call(EnumLanguageSelection.en);
          },
        ),
        MenuItemButton(
          child: Text("language.locale.fr".tr()),
          onPressed: () {
            onSelectLanguage?.call(EnumLanguageSelection.fr);
          },
        ),
      ],
      builder: (
        BuildContext context,
        MenuController controller,
        Widget? child,
      ) {
        final String languageSelected = autoDetectedLanguage.isEmpty
            ? languageSelection.name
            : autoDetectedLanguage;

        return TextButton(
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: isDark ? Colors.black : Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${"language.name".tr()}: "
                "${"language.locale.$languageSelected".tr()}",
              ),
              if (languageSelection == EnumLanguageSelection.autoDetect)
                const Icon(TablerIcons.bolt, size: 14.0),
            ],
          ),
        );
      },
    );
  }
}
