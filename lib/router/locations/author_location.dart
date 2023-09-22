import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/author/author_page.dart";

class AuthorLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  /// Navigate to the author's page.
  static const String route = "/author/:authorId";

  @override
  List<Pattern> get pathPatterns => [
        route,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: AuthorPage(
          authorId: state.pathParameters["authorId"] ?? "",
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
