import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/home/quote_page.dart";
import "package:kwotes/screens/search/search_page.dart";

class SearchLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/s";

  /// Quote route location for search.
  static const String quoteRoute = "$route/:quoteId";

  @override
  List<String> get pathPatterns => [
        route,
        quoteRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SearchPage(
          query: extractQuery(state.routeState),
          subjectName: extractSubjectName(state.routeState),
        ),
        key: const ValueKey(route),
        title: "page_title.search".tr(),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains(":quoteId"))
        BeamPage(
          child: QuotePage(
            quoteId: state.pathParameters["quoteId"] ?? "",
          ),
          key: const ValueKey(quoteRoute),
          title: "page_title.any".tr(),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
    ];
  }

  String extractQuery(Object? routeState) {
    if (routeState == null) {
      return "";
    }

    if (routeState is Map) {
      return routeState["query"] ?? "";
    }

    return "";
  }

  String extractSubjectName(Object? routeState) {
    if (routeState == null) {
      return "";
    }

    if (routeState is Map) {
      return routeState["subjectName"] ?? "";
    }

    return "";
  }
}
