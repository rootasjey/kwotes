import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:wave_divider/wave_divider.dart";

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: true,
    );

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onTapBackButton: context.beamBack,
              title: "about.us".tr(),
            ),
            SliverPadding(
              padding: isMobileSize
                  ? const EdgeInsets.only(
                      top: 0.0,
                      left: 24.0,
                      right: 24.0,
                      bottom: 200.0,
                    )
                  : const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 48.0,
                    ),
              sliver: SliverToBoxAdapter(
                child: FractionallySizedBox(
                  widthFactor: isMobileSize ? 0.90 : 0.80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMobileSize)
                        IconButton(
                          onPressed: () => Utils.passage.deepBack(context),
                          icon: const Icon(TablerIcons.arrow_left),
                          style: IconButton.styleFrom(
                            backgroundColor: accentColor.withOpacity(0.1),
                          ),
                        ),
                      if (!isMobileSize)
                        Text(
                          "purpose.name".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 84.0,
                              fontWeight: FontWeight.w700,
                              color: Constants.colors.getRandomFromPalette(
                                onlyDarkerColors: true,
                              ),
                            ),
                          ),
                        ),
                      const WaveDivider(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "purpose.content.0".tr(),
                          children: [
                            TextSpan(
                              text: " ${"purpose.content.1".tr()}",
                            ),
                            TextSpan(
                              text: " ${"purpose.content.2".tr()}",
                            ),
                            TextSpan(
                              text: " ${"purpose.content.3".tr()}.",
                              style: TextStyle(
                                color: Constants.colors.getRandomFromPalette(
                                  onlyDarkerColors: true,
                                ),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: "\n\n${"purpose.content.4".tr()}",
                            ),
                            TextSpan(
                              text: "purpose.content.5".tr(),
                            ),
                            TextSpan(
                              text: "purpose.content.6".tr(),
                            ),
                            TextSpan(
                              text: "\n\n${"purpose.content.7".tr()}",
                            ),
                            TextSpan(
                              text: " ${"purpose.content.8".tr()}",
                            ),
                          ],
                        ),
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: isMobileSize ? 16.0 : 24.0,
                            fontWeight: FontWeight.w300,
                            color: foregroundColor?.withOpacity(0.6),
                          ),
                        ),
                      ),
                      ColoredTextButton(
                        textFlex: 0,
                        textValue: "back".tr(),
                        onPressed: () => Utils.passage.deepBack(context),
                        icon: const Icon(TablerIcons.arrow_narrow_left),
                        margin: const EdgeInsets.only(
                          top: 42.0,
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: accentColor.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}