import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/theme_chip.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

class AppLanguageSelection extends StatelessWidget {
  const AppLanguageSelection({
    super.key,
    this.animateElements = false,
    this.isMobileSize = false,
    this.accentColor = Colors.pink,
    this.dividerColor,
    this.dividerHeight = 48.0,
    this.foregroundColor,
    this.onSelectLanguage,
    this.currentLanguageCode,
  });

  /// Animate elements on settings page if true.
  final bool animateElements;

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

  /// Callback fired when a language is selected.
  final void Function(EnumLanguageSelection locale)? onSelectLanguage;

  /// Current language code.
  final String? currentLanguageCode;

  @override
  Widget build(BuildContext context) {
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
              fontSize: isMobileSize ? 32.0 : 72.0,
              fontWeight: FontWeight.w100,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: animateElements ? 250.ms : 0.ms)
            .slideY(begin: 0.8, end: 0.0),
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
              .fadeIn(duration: animateElements ? 150.ms : 0.ms)
              .slideY(begin: 0.8, end: 0.0),
        ),
        Divider(
          height: dividerHeight,
          color: dividerColor,
        )
            .animate(delay: animateElements ? 250.ms : 0.ms)
            .fadeIn(duration: animateElements ? 250.ms : 0.ms)
            .slideY(begin: 0.8, end: 0.0),
      ]),
    );
  }
}
