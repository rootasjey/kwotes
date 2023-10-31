import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/home/quote_page.dart";
import "package:kwotes/screens/home/responsive_app_container.dart";

class HomeLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/";

  /// Quote route location for home.
  static const String quoteRoute = "/r/:quoteId";

  @override
  List<Pattern> get pathPatterns => [
        route,
        quoteRoute,
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
}
