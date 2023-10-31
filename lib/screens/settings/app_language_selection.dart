import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/theme_chip.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

class AppLanguageSelection extends StatelessWidget {
  const AppLanguageSelection({
    super.key,
    this.isMobileSize = false,
    this.onSelectLanguage,
    this.currentLanguageCode,
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Callback fired when a language is selected.
  final void Function(EnumLanguageSelection locale)? onSelectLanguage;

  /// Current language code.
  final String? currentLanguageCode;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color accentColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );
    final Color foregroundAccentColor =
        accentColor.computeLuminance() > 0.4 ? Colors.black : Colors.white;

    return SliverPadding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
          : const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0),
      sliver: SliverList.list(children: [
        Text.rich(
          TextSpan(text: "${"language.name".tr()}: ", children: [
            TextSpan(
              text: "language.locale.$currentLanguageCode".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ]),
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: isMobileSize ? 42.0 : 72.0,
              fontWeight: FontWeight.w100,
              color: foregroundColor?.withOpacity(0.6),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.8, end: 0.0, duration: 250.ms),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: Utils.linguistic
              .available()
              .map(
                (locale) => ThemeChip(
                  textLabel: "language.locale.${locale.name}".tr(),
                  selected: currentLanguageCode == locale.name,
                  accentColor: accentColor,
                  foregroundColor: currentLanguageCode == locale.name
                      ? foregroundAccentColor
                      : foregroundColor?.withOpacity(0.6),
                  onTap: () => onSelectLanguage?.call(locale),
                ),
              )
              .toList()
              .animate(interval: 150.ms)
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.8, end: 0.0, duration: 150.ms),
        ),
        const Divider(
          height: 48.0,
        )
            .animate(delay: 250.ms)
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.8, end: 0.0, duration: 250.ms),
      ]),
    );
  }
}
