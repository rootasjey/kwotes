import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/theme_chip.dart";

class AppBehaviourSettings extends StatelessWidget {
  /// Customize application behaviour.
  const AppBehaviourSettings({
    super.key,
    this.isMobileSize = false,
    this.animateElements = false,
    this.isFullscreenQuotePage = false,
    this.onToggleFullscreen,
  });

  /// Animate elements on settings page if true.
  final bool animateElements;

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Whether quote page is fullscreen.
  final bool isFullscreenQuotePage;

  /// Callback fired to toggle quote page fullscreen.
  final void Function()? onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color accentColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );

    final Color foregroundAccentColor =
        accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return SliverPadding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
          : const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0),
      sliver: SliverList.list(children: [
        Text.rich(
          TextSpan(text: "${"settings.behaviour.name".tr()}: ", children: [
            TextSpan(
              text: "settings.fullscreen_quote_page.name".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              recognizer: TapGestureRecognizer()..onTap = onToggleFullscreen,
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
            .fadeIn(duration: animateElements ? 250.ms : 0.ms)
            .slideY(begin: 0.8, end: 0.0),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            ThemeChip(
              textLabel: "on".tr(),
              selected: isFullscreenQuotePage,
              accentColor: accentColor,
              foregroundColor: isFullscreenQuotePage
                  ? foregroundAccentColor
                  : foregroundColor?.withOpacity(0.6),
              onTap: onToggleFullscreen,
            ),
            ThemeChip(
              textLabel: "off".tr(),
              selected: !isFullscreenQuotePage,
              accentColor: accentColor,
              foregroundColor: !isFullscreenQuotePage
                  ? foregroundAccentColor
                  : foregroundColor?.withOpacity(0.6),
              onTap: onToggleFullscreen,
            ),
          ]
              .animate(interval: animateElements ? 150.ms : 0.ms)
              .fadeIn(duration: animateElements ? 150.ms : 0.ms)
              .slideY(begin: 0.8, end: 0.0),
        ),
        const Divider(
          height: 48.0,
        )
            .animate(delay: animateElements ? 250.ms : 0.ms)
            .fadeIn(duration: animateElements ? 250.ms : 0.ms)
            .slideY(begin: 0.8, end: 0.0),
      ]),
    );
  }
}
