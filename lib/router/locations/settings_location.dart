import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/color_palette/color_palette_page.dart";
import "package:kwotes/screens/settings/settings_page.dart";

class SettingsLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/settings";
  static const String colorPalette = "$route/color-palette";

  @override
  List<String> get pathPatterns => [
        route,
        colorPalette,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const SettingsPage(),
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
    ];
  }
}
