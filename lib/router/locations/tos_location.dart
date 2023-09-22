import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/tos_page.dart";

class TosLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/tos";

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const TosPage(),
        key: const ValueKey(route),
        title: "page_title.tos".tr(),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
