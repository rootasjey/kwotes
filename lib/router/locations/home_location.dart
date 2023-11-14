import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/author/author_page.dart";
import "package:kwotes/screens/author/author_quotes_page.dart";
import "package:kwotes/screens/home/mobile_home_page.dart";
import "package:kwotes/screens/home/quote_page.dart";
import "package:kwotes/screens/home/responsive_app_container.dart";
import "package:kwotes/screens/home/topic_page.dart";
import "package:kwotes/screens/reference/reference_page.dart";
import "package:kwotes/screens/reference/reference_quotes_page.dart";

class HomeLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/";

  /// Alternate home location for deep navigation.
  static const String routeWildCard = "/h/*";

  @override
  List<Pattern> get pathPatterns => [
        route,
        routeWildCard,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const ResponsiveAppContainer(),
        key: const ValueKey(route),
        title: "page_title.home".tr(),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}

class HomeContentLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/h";

  /// Author route location.
  static const String authorRoute = "$route/author/:authorId";

  /// Author's quotes route location.
  static const String authorQuotesRoute = "$authorRoute/quotes";

  /// Author's single quote route location.
  /// e.g. `/h/author/authorId/quotes/quoteId`
  /// Useful to keep previous author page(s) below this one.
  static const String authorQuoteRoute = "$authorRoute/quotes/:quoteId";

  /// Quote route location.
  static const String quoteRoute = "$route/quote/:quoteId";

  /// Reference route location.
  static const String referenceRoute = "$route/reference/:referenceId";

  /// Reference's quotes route location.
  static const String referenceQuotesRoute = "$referenceRoute/quotes";

  /// Reference's single quote route location.
  /// e.g. `/h/reference/authorId/quotes/quoteId`
  /// Useful to keep previous reference page(s) below this one.
  static const String referenceQuoteRoute = "$referenceRoute/quotes/:quoteId";

  /// Topic route location for home.
  static const String topicRoute = "$route/topic/:topicName";

  /// Quote route location on top of topic page.
  static const String topicQuoteRoute = "$topicRoute/quote/:quoteId";

  @override
  List<String> get pathPatterns => [
        authorRoute,
        authorQuotesRoute,
        authorQuoteRoute,
        quoteRoute,
        referenceRoute,
        referenceQuotesRoute,
        referenceQuoteRoute,
        topicRoute,
        topicQuoteRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const MobileHomePage(),
        key: const ValueKey(route),
        title: "page_title.home".tr(),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains(topicRoute.split("/").last))
        BeamPage(
          child: TopicPage(
            topic: state.pathParameters["topicName"] ?? "",
          ),
          key: const ValueKey(topicRoute),
          title: "page_title.any".tr(),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
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
      if (state.pathPatternSegments.contains(authorRoute.split("/").last) &&
          state.pathPatternSegments.contains(authorQuotesRoute.split("/").last))
        BeamPage(
          child: AuthorQuotesPage(
            authorId: state.pathParameters["authorId"] ?? "",
          ),
          key: const ValueKey(authorQuotesRoute),
          title: "page_title.any".tr(),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains(referenceRoute.split("/").last) &&
          state.pathPatternSegments
              .contains(referenceQuotesRoute.split("/").last))
        BeamPage(
          child: ReferenceQuotesPage(
            referenceId: state.pathParameters["referenceId"] ?? "",
          ),
          key: const ValueKey(referenceQuotesRoute),
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
}
