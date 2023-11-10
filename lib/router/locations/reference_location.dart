import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/reference/reference_page.dart";

class ReferenceLocation extends BeamLocation<BeamState> {
  static const String route = "/reference/:referenceId";

  @override
  List<Pattern> get pathPatterns => [
        route,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      if (state.pathPatternSegments.contains(route.split("/").last))
        BeamPage(
          child: ReferencePage(
            referenceId: state.pathParameters["referenceId"] ?? "",
          ),
          key: const ValueKey(route),
          title: "page_title.any".tr(),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
    ];
  }
}
