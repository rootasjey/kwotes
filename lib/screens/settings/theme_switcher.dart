import "package:adaptive_theme/adaptive_theme.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/theme_chip.dart";

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final bool lightSelected =
        AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light;

    final bool darkSelected =
        AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final bool systemSelected =
        AdaptiveTheme.of(context).mode == AdaptiveThemeMode.system;

    final Color accentColor = Constants.colors.getRandomFromPalette();
    final Color foregroundAccentColor =
        accentColor.computeLuminance() > 0.4 ? Colors.black : Colors.white;

    return SliverPadding(
      padding: const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0),
      sliver: SliverList.list(children: [
        Text.rich(
          TextSpan(text: "${"theme".tr()}: ", children: [
            TextSpan(
              text: AdaptiveTheme.of(context).mode.modeName.toLowerCase().tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  AdaptiveTheme.of(context).toggleThemeMode();
                },
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
          children: [
            ThemeChip(
              textLabel: "light".tr(),
              selected: lightSelected,
              accentColor: accentColor,
              foregroundColor: lightSelected
                  ? foregroundAccentColor
                  : foregroundColor?.withOpacity(0.6),
              onTap: AdaptiveTheme.of(context).setLight,
            ),
            ThemeChip(
              textLabel: "dark".tr(),
              selected: darkSelected,
              accentColor: accentColor,
              foregroundColor: darkSelected
                  ? foregroundAccentColor
                  : foregroundColor?.withOpacity(0.6),
              onTap: AdaptiveTheme.of(context).setDark,
            ),
            ThemeChip(
              textLabel: "system".tr(),
              selected: systemSelected,
              accentColor: accentColor,
              foregroundColor: systemSelected
                  ? foregroundAccentColor
                  : foregroundColor?.withOpacity(0.6),
              onTap: AdaptiveTheme.of(context).setSystem,
            ),
          ]
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
