import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/color_palette/color_palette_page.dart";
import "package:kwotes/screens/settings/about/terms_of_service_page.dart";
import "package:kwotes/screens/settings/about/the_purpose_page.dart";
import "package:kwotes/screens/settings/settings_page.dart";

class SettingsLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/settings";
  static const String colorPalette = "$route/color-palette";
  static const String tosRoute = "$route/terms-of-service";
  static const String thePurposeRoute = "$route/the-purpose";

  @override
  List<String> get pathPatterns =>
      [route, colorPalette, tosRoute, thePurposeRoute];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const SettingsPage(
          selfPageShortcutsActive: true,
        ),
        key: const ValueKey(route),
        title: "page_title.settings".tr(),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains(colorPalette.split("/").last))
        BeamPage(
          child: const ColorPalettePage(),
          key: const ValueKey(colorPalette),
          title: "page_title.about".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(route.split("/").last) &&
          state.pathPatternSegments.contains(tosRoute.split("/").last))
        BeamPage(
          child: const TermsOfServicePage(),
          key: const ValueKey(tosRoute),
          title: "page_title.terms_of_service".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(route.split("/").last) &&
          state.pathPatternSegments.contains(thePurposeRoute.split("/").last))
        BeamPage(
          child: const ThePurposePage(),
          key: const ValueKey(thePurposeRoute),
          title: "page_title.the_purpose".tr(),
          type: BeamPageType.fadeTransition,
        ),
    ];
  }
}
