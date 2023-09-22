import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/theme_chip.dart";

class AppLanguageSelection extends StatelessWidget {
  const AppLanguageSelection({
    super.key,
    this.onSelectLanguage,
    this.currentLanguageCode,
  });

  /// Callback fired when a language is selected.
  final void Function(String locale)? onSelectLanguage;

  /// Current language code.
  final String? currentLanguageCode;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color accentColor = Constants.colors.getRandomFromPalette();
    final Color foregroundAccentColor =
        accentColor.computeLuminance() > 0.4 ? Colors.black : Colors.white;

    return SliverPadding(
      padding: const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0),
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
              fontSize: 72.0,
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
                  textLabel: "language.locale.$locale".tr(),
                  selected: currentLanguageCode == locale,
                  accentColor: accentColor,
                  foregroundColor: currentLanguageCode == locale
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
