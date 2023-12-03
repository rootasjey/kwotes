import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({
    super.key,
    this.margin = EdgeInsets.zero,
    this.onChangeLanguage,
  });

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when language is changed.
  final void Function(EnumLanguageSelection locale)? onChangeLanguage;

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final String? currentLanguageCode =
        EasyLocalization.of(context)?.currentLocale?.languageCode;

    return Padding(
      padding: widget.margin,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          Text(
            "${"language.name".tr()} : ",
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                color: foregroundColor?.withOpacity(0.8),
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...Utils.linguistic.available().map((locale) {
            final bool selected = currentLanguageCode == locale.name;

            return ColoredTextButton(
              textFlex: 0,
              textValue: "language.locale.${locale.name}".tr(),
              accentColor: selected ? Constants.colors.tertiary : null,
              icon: selected
                  ? Icon(
                      TablerIcons.check,
                      size: 18.0,
                      color: selected ? Constants.colors.tertiary : null,
                    )
                  : null,
              onPressed: () {
                Utils.vault.setLanguage(locale);
                EasyLocalization.of(context)?.setLocale(Locale(locale.name));
                widget.onChangeLanguage?.call(locale);
              },
              textStyle: TextStyle(
                color: selected ? Constants.colors.tertiary : null,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
