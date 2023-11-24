import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/theme_chip.dart";

class AppBehaviourSettings extends StatelessWidget {
  /// Customize application behaviour.
  const AppBehaviourSettings({
    super.key,
    this.isMobileSize = false,
    this.animateElements = false,
    this.isFullscreenQuotePage = false,
    this.isMinimalQuoteActions = false,
    this.accentColor = Colors.blue,
    this.foregroundColor,
    this.onToggleFullscreen,
    this.onToggleMinimalQuoteActions,
  });

  /// Animate elements on settings page if true.
  final bool animateElements;

  /// Whether quote page is fullscreen.
  final bool isFullscreenQuotePage;

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Hide [close], [copy] actions if this is true.
  final bool isMinimalQuoteActions;

  /// Accent color.
  final Color accentColor;

  /// Text foreground color.
  final Color? foregroundColor;

  /// Callback fired to toggle quote page fullscreen.
  final void Function()? onToggleFullscreen;

  /// Callback fired to toggle minimal quote action setting.
  final void Function()? onToggleMinimalQuoteActions;

  @override
  Widget build(BuildContext context) {
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
              text: "settings.ui".tr(),
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
              tooltip: "settings.fullscreen_quote_page.description".tr(),
              textLabel:
                  "settings.behaviour.fullscreen_quote_page.$isFullscreenQuotePage"
                      .tr(),
              selected: isFullscreenQuotePage,
              accentColor: accentColor,
              foregroundColor: foregroundAccentColor,
              // foregroundColor: isFullscreenQuotePage
              //     ? foregroundAccentColor
              //     : foregroundColor?.withOpacity(0.6),
              onTap: onToggleFullscreen,
            ),
            ThemeChip(
              tooltip: "settings.minimal_quote_actions.description".tr(),
              textLabel:
                  "settings.behaviour.minimal_quote_actions.$isMinimalQuoteActions"
                      .tr(),
              selected: isMinimalQuoteActions,
              accentColor: accentColor,
              foregroundColor: foregroundAccentColor,
              // foregroundColor: isMinimalQuoteActions
              //     ? foregroundAccentColor
              //     : foregroundColor?.withOpacity(0.6),
              onTap: onToggleMinimalQuoteActions,
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
