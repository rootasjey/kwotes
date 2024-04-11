import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:wave_divider/wave_divider.dart";

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: true,
    );

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final String subtitle = "${"date.last_updated".tr()} : "
        "${Jiffy.parseFromDateTime(Constants.termsOfServiceLastUpdated).yMMMMEEEEd}";

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onTapBackButton: context.beamBack,
              title: "tos.name".tr(),
              subtitle: subtitle,
            ),
            SliverPadding(
              padding: isMobileSize
                  ? const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 48.0)
                  : const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 48.0,
                    ),
              sliver: SliverToBoxAdapter(
                child: FractionallySizedBox(
                  widthFactor: isMobileSize ? 0.9 : 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WaveDivider(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "${"tos.content.0".tr()}\n\n",
                          children: [
                            TextSpan(
                              text: "${"tos.content.1".tr()}\n\n",
                            ),
                            TextSpan(
                              text: "${"tos.content.2".tr()}\n\n",
                            ),
                            TextSpan(
                              text: "${"tos.content.3".tr()}\n\n",
                            ),
                            TextSpan(
                              text: "${"tos.content.4".tr()}\n\n",
                            ),
                            TextSpan(
                              text: "${"tos.content.5".tr()}\n\n",
                            ),
                            TextSpan(
                              text: "${"tos.content.6".tr()}\n\n",
                            ),
                            TextSpan(
                              text: "${"tos.content.7".tr()}\n\n",
                            ),
                          ],
                        ),
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: isMobileSize ? 14.0 : 24.0,
                            fontWeight: FontWeight.w400,
                            color: foregroundColor?.withOpacity(0.5),
                          ),
                        ),
                      ),
                      ColoredTextButton(
                        textFlex: 0,
                        textValue: "back".tr(),
                        onPressed: () => Utils.passage.deepBack(context),
                        icon: const Icon(TablerIcons.arrow_narrow_left),
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
