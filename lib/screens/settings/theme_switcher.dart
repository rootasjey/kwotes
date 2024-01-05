import "package:adaptive_theme/adaptive_theme.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/theme_chip.dart";

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({
    super.key,
    this.animateElements = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.accentColor = Colors.amber,
    this.dividerColor,
    this.dividerHeight = 48.0,
    this.foregroundColor,
    this.onTapLightTheme,
    this.onTapDarkTheme,
    this.onTapSystemTheme,
    this.onToggleThemeMode,
  });

  /// Animate elements on settings page if true.
  final bool animateElements;

  /// Dark theme if true.
  final bool isDark;

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Accent color.
  final Color accentColor;

  /// Divider color.
  final Color? dividerColor;

  /// Text foreground color.
  final Color? foregroundColor;

  /// Divider height.
  final double? dividerHeight;

  /// Callback fired when light theme is selected.
  final void Function()? onTapLightTheme;

  /// Callback fired when dark theme is selected.
  final void Function()? onTapDarkTheme;

  /// Callback fired when system theme is selected.
  final void Function()? onTapSystemTheme;

  /// Callback fired when theme mode is toggled.
  final void Function()? onToggleThemeMode;

  @override
  Widget build(BuildContext context) {
    final bool lightSelected =
        AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light;

    final bool darkSelected =
        AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final bool systemSelected =
        AdaptiveTheme.of(context).mode == AdaptiveThemeMode.system;

    final Color foregroundAccentColor =
        accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return SliverPadding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
          : const EdgeInsets.only(top: 42.0, left: 48.0, right: 72.0),
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
              recognizer: TapGestureRecognizer()..onTap = onToggleThemeMode,
            ),
          ]),
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: isMobileSize ? 32.0 : 32.0,
              fontWeight: isMobileSize ? FontWeight.w100 : FontWeight.w400,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: animateElements ? 250.ms : 0.ms)
            .slideY(begin: 0.8, end: 0.0),
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
              onTap: onTapLightTheme,
            ),
            ThemeChip(
              textLabel: "dark".tr(),
              selected: darkSelected,
              accentColor: accentColor,
              foregroundColor: darkSelected
                  ? foregroundAccentColor
                  : foregroundColor?.withOpacity(0.6),
              onTap: onTapDarkTheme,
            ),
            ThemeChip(
              textLabel: "system".tr(),
              selected: systemSelected,
              accentColor: accentColor,
              foregroundColor: systemSelected
                  ? foregroundAccentColor
                  : foregroundColor?.withOpacity(0.6),
              onTap: onTapSystemTheme,
            ),
          ]
              .animate(interval: animateElements ? 150.ms : 0.ms)
              .fadeIn(duration: animateElements ? 250.ms : 0.ms)
              .slideY(begin: 0.8, end: 0.0),
        ),
        Divider(
          height: dividerHeight,
          color: isDark ? Colors.white12 : Colors.black12,
        )
            .animate(delay: animateElements ? 250.ms : 0.ms)
            .fadeIn(duration: animateElements ? 250.ms : 0.ms)
            .slideY(begin: 0.8, end: 0.0),
      ]),
    );
  }
}
