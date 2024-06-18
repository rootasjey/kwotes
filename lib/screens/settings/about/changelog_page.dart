import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/about/big_text_header.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:wave_divider/wave_divider.dart";

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onTapBackButton: context.beamBack,
              title: "changelog.name".tr(),
              subtitle: "changelog.description".tr(),
              show: isMobileSize,
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
                      BigTextHeader(
                        show: !isMobileSize,
                        accentColor: foregroundColor,
                        titleValue: "changelog.name".tr(),
                        subtitleValue:
                            "App version: ${Constants.appVersion} • build ${Constants.appBuildNumber}",
                        // subtitleValue: "changelog.description".tr(),
                      ),
                      // Text(
                      //   "App version: ${Constants.appVersion} • build ${Constants.appBuildNumber}",
                      //   style: Utils.calligraphy.body(
                      //     textStyle: TextStyle(
                      //       fontSize: 14.0,
                      //       fontWeight: FontWeight.w500,
                      //       color: foregroundColor?.withOpacity(0.6),
                      //     ),
                      //   ),
                      // ),
                      WaveDivider(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobileSize ? 24.0 : 48.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                          "update.last".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w200,
                              color: foregroundColor?.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "18/06/2024",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w200,
                                    color: foregroundColor?.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update premium prices",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add new carrott badge on premium avatar",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Redirect to \"My Quotes\" page after saving a quote",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add new quote button on \"My Quotes\" page",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add publish button on quote page",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Fix keyboard layout issue (iOS)",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: foregroundColor?.withOpacity(0.2),
                        height: 42.0,
                      ),
                      Text(
                        "Previously",
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w200,
                            color: foregroundColor?.withOpacity(0.8),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "14/06/2024",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w200,
                                    color: foregroundColor?.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add premium features: topics, search, unlimited lists, unlimited quotes",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add premium paywall",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Bug fixes",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "01/05/2024",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w200,
                                    color: foregroundColor?.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add in-app purchases",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update search page",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update author & reference pages",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "23/04/2024",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w200,
                                    color: foregroundColor?.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update add to list dialog/bottom sheet",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add user actions on author/reference quotes pages",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Fix search issue provoking app crashes",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Fix showing empty view when no search results are found",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Fix share issue on iPad/iOS due to missing origin position value",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update app bottom navigation on large screens",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update swipe gesture design",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Save language selection on author & reference quotes pages",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update colors of the following components: search input, add quote appbar",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Remove application frame border on large screens",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Fix cancel button clearing search input",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add pull & push quick gestures on dashboard page",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add pull gesture on search page",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update quote page font size (iPad)",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update share icon & other tweaks",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "19/04/2024",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w200,
                                    color: foregroundColor?.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Fix avatar size & spacing issue",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Remove unnecessary ownership filter on published quotes tab",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Remove floating action buttons on \"My Quotes\" page & \"Lists\" page",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "10/04/2024",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w200,
                                    color: foregroundColor?.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Redesign settings page",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update default profile picture",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add user avatar on home, search & diary page (to access settings)",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update search page (font, header, input)",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add changelog page",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Save last tab selected on \"My Quotes\" page",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "03/04/2024",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w200,
                                    color: foregroundColor?.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Add swipe action on quote items",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Update dashboard card order",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "• Merge drafts, in validation & published pages",
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: foregroundColor?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
