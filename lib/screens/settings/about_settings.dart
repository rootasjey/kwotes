import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/like_button_vanilla.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class AboutSettings extends StatefulWidget {
  /// About section on settings page.
  const AboutSettings({
    super.key,
    this.animateElements = false,
    this.isMobileSize = false,
    this.foregroundColor,
    this.onTapColorPalette,
    this.onTapTermsOfService,
    this.onTapGitHub,
    this.onTapThePurpose,
  });

  /// Animate elements on settings page if true.
  final bool animateElements;

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Text foreground color.
  final Color? foregroundColor;

  /// Callback fired when "Color palette" button is tapped.
  final void Function()? onTapColorPalette;

  /// Callback fired when "Terms of service" chip is tapped.
  final void Function()? onTapTermsOfService;

  /// Callback fired when "GitHub" chip is tapped.
  final void Function()? onTapGitHub;

  /// Callback fired when "The purpose" chip is tapped.
  final void Function()? onTapThePurpose;

  @override
  State<AboutSettings> createState() => _AboutSettingsState();
}

class _AboutSettingsState extends State<AboutSettings> {
  @override
  Widget build(BuildContext context) {
    const double iconSize = 48.0;

    return SliverPadding(
      padding: widget.isMobileSize
          ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
          : const EdgeInsets.only(
              top: 12.0,
              left: 48.0,
              right: 72.0,
              bottom: 120.0,
            ),
      sliver: SliverList.list(children: [
        Text.rich(
          TextSpan(
            text: "${"about.name".tr()}: ",
            children: const [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: LikeButtonVanilla(
                    size: Size(iconSize, iconSize),
                  ),
                ),
              ),
            ],
          ),
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 32.0,
              fontWeight:
                  widget.isMobileSize ? FontWeight.w100 : FontWeight.w400,
              color: widget.foregroundColor,
            ),
          ),
        )
            .animate(delay: widget.animateElements ? 350.ms : 0.ms)
            .fadeIn(duration: widget.animateElements ? 150.ms : 0.ms)
            .slideY(begin: 0.8, end: 0.0),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                ActionChip(
                  onPressed: widget.onTapColorPalette,
                  label: Text("color.palette".tr()),
                  shape: const StadiumBorder(),
                ),
                ActionChip(
                  onPressed: widget.onTapTermsOfService,
                  label: Text("tos.name".tr()),
                  shape: const StadiumBorder(),
                ),
                ActionChip(
                  onPressed: widget.onTapThePurpose,
                  shape: const StadiumBorder(),
                  label: Text("purpose.the".tr()),
                ),
                ActionChip(
                  onPressed: widget.onTapGitHub,
                  shape: const StadiumBorder(),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("GitHub"),
                      Icon(
                        TablerIcons.arrow_up_right,
                        size: 16.0,
                        color: widget.foregroundColor?.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                ActionChip(
                  label: Text("${"version".tr()}: ${Constants.appVersion}"),
                  shape: const StadiumBorder(),
                ),
              ]
                  .animate(
                    delay: widget.animateElements ? 300.ms : 0.ms,
                    interval: widget.animateElements ? 50.ms : 0.ms,
                  )
                  .fadeIn(duration: widget.animateElements ? 150.ms : 0.ms)
                  .slideY(begin: 0.8, end: 0.0),
            ),
          ),
        )
      ]),
    );
  }
}
