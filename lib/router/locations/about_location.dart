import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/settings/about/about_us_page.dart";
import "package:kwotes/screens/settings/about/changelog_page.dart";
import "package:kwotes/screens/settings/about/credits_page.dart";
import "package:kwotes/screens/settings/about/terms_of_service_page.dart";

class AboutLocation extends BeamLocation<BeamState> {
  static const String aboutUsRoute = "/about-us";
  static const String changelogRoute = "/changelog";
  static const String creditsRoute = "/credits";
  static const String tosRoute = "/privacy";

  @override
  List<String> get pathPatterns => [
        aboutUsRoute,
        changelogRoute,
        creditsRoute,
        tosRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      if (state.pathPatternSegments.contains(aboutUsRoute.split("/").last))
        BeamPage(
          child: const AboutUsPage(),
          key: const ValueKey(aboutUsRoute),
          title: "page_title.about_us".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(tosRoute.split("/").last))
        BeamPage(
          child: const TermsOfServicePage(),
          key: const ValueKey(tosRoute),
          title: "page_title.tos".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(changelogRoute.split("/").last))
        BeamPage(
          child: const ChangelogPage(),
          key: const ValueKey(changelogRoute),
          title: "page_title.changelog".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(creditsRoute.split("/").last))
        BeamPage(
          child: const CreditsPage(),
          key: const ValueKey(creditsRoute),
          title: "page_title.credits".tr(),
          type: BeamPageType.fadeTransition,
        ),
    ];
  }
}
