import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/author/author_page.dart";
import "package:kwotes/screens/author/edit_author_page.dart";
import "package:kwotes/screens/quote_page/quote_page.dart";
import "package:kwotes/screens/reference/edit_reference_page.dart";
import "package:kwotes/screens/reference/reference_page.dart";
import "package:kwotes/screens/search/search_page.dart";
import "package:kwotes/screens/search/search_navigation_page.dart";

class SearchLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/s";

  /// Alternate home location for deep navigation.
  static const String routeWildCard = "/s/*";

  @override
  List<String> get pathPatterns => [
        route,
        routeWildCard,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const SearchNavigationPage(),
        key: const ValueKey(route),
        title: "page_title.search".tr(),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}

class SearchContentLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/s";

  /// Author route location.
  static const String authorRoute = "$route/author/:authorId";

  /// Edit author route location.
  static const String editAuthorRoute = "$route/edit/author/:authorId";

  /// Edit reference route location.
  static const String editReferenceRoute = "$route/edit/reference/:referenceId";

  /// Quote route location.
  static const String quoteRoute = "$route/quote/:quoteId";

  /// Reference route location.
  static const String referenceRoute = "$route/reference/:referenceId";

  /// Topic route location.
  static const String topicRoute = "$route/topic/:topicName";

  /// Quote route location on top of topic page.
  static const String topicQuoteRoute = "$topicRoute/quote/:quoteId";

  @override
  List<String> get pathPatterns => [
        route,
        quoteRoute,
        authorRoute,
        editAuthorRoute,
        editReferenceRoute,
        referenceRoute,
        topicRoute,
        topicQuoteRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SearchPage(
          query: extractQuery(state.routeState),
          subjectName: extractSubjectName(state.routeState),
        ),
        key: ValueKey("$route-${extractQuery(state.routeState)}"),
        title: "page_title.search".tr(),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains(authorRoute.split("/").last))
        BeamPage(
          child: AuthorPage(
            authorId: state.pathParameters["authorId"] ?? "",
          ),
          key: const ValueKey(authorRoute),
          title: "page_title.any".tr(),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains(referenceRoute.split("/").last))
        BeamPage(
          child: ReferencePage(
            referenceId: state.pathParameters["referenceId"] ?? "",
          ),
          key: const ValueKey(referenceRoute),
          title: "page_title.any".tr(),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains("edit") &&
          state.pathPatternSegments.contains(":authorId"))
        BeamPage(
          child: EditAuthorPage(
            authorId: state.pathParameters["authorId"] ?? "",
          ),
          key: const ValueKey(editAuthorRoute),
          title: "page_title.any".tr(),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains("edit") &&
          state.pathPatternSegments.contains(":referenceId"))
        BeamPage(
          child: EditReferencePage(
            referenceId: state.pathParameters["referenceId"] ?? "",
          ),
          key: const ValueKey(editReferenceRoute),
          title: "page_title.any".tr(),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains(quoteRoute.split("/").last))
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
