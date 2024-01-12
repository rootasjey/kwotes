import "package:beamer/beamer.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/search_location.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_frame_border_style.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/quote_list.dart";
import "package:kwotes/types/reference.dart";

/// Helper class which contains additional navigation states.
class NavigationStateHelper {
  /// Selected author and passed through author page.
  static Author author = Author.empty();

  /// Show quote page in fullscreen (hiding the navigation bar) if true.
  /// We need this property on top of the local storage
  /// in order to syncronously know where to navigate (with the router).
  static bool fullscreenQuotePage = true;

  /// Hide duplicated actions (e.g. [close], [copy]) on quote page,
  /// if this is true.
  static bool minimalQuoteActions = false;

  /// Show header page options (e.g. language) if true.
  static bool showHeaderPageOptions = true;

  /// App frame border style.
  static EnumFrameBorderStyle frameBorderStyle = EnumFrameBorderStyle.discrete;

  /// Current home page index (useful on mobile screen size).
  /// 0: home, 1: search, 2: dashboard.
  /// This will avoid having delay when retrieving value from local storage.
  static int homePageTabIndex = 0;

  /// Random quotes for home page.
  static List<Quote> randomQuotes = [];

  /// Latest added authors.
  static List<Author> latestAddedAuthors = [];

  /// Latest added references.
  static List<Reference> latestAddedReferences = [];

  /// Selected reference and passed through reference page.
  static Reference reference = Reference.empty();

  /// Selected quote and passed through quote page.
  static Quote quote = Quote.empty();

  /// Selected quote list and passed through quote list page.
  static QuoteList quoteList = QuoteList.empty();

  /// Last random quote language.
  /// Useful for fetching new random quotes after a language change.
  static String lastRandomQuoteLanguage = "en";

  /// Last topic name.
  static String lastTopicName = "";

  /// Search value.
  /// This value will be passed to the search page on navigation.
  /// Thus keeping context when navigating back and forth result pages.
  static String searchValue = "";

  /// Initial browser url.
  /// Necesarry to set app locale somewhere where we've access to a `context`.
  /// We cannot set it in the `main` method because the `context`
  /// is not available there.
  static String initialBrowserUrl = "";

  /// Beamer key to navigate sub-locations.
  static GlobalKey<BeamerState> homeBeamerKey = GlobalKey<BeamerState>(
    debugLabel: "home",
  );

  /// Beamer delegate to navigate home sub-locations.
  /// NOTE: Create delegate outside build method in order to avoid state issues.
  static BeamerDelegate homeRouterDelegate = BeamerDelegate(
    initialPath: HomeContentLocation.route,
    locationBuilder: BeamerLocationBuilder(beamLocations: [
      HomeContentLocation(BeamState.fromUriString(HomeContentLocation.route)),
    ]),
  );

  /// Beamer key to navigate search sub-locations.
  static GlobalKey<BeamerState> searchBeamerKey = GlobalKey<BeamerState>(
    debugLabel: "search",
  );

  /// Beamer delegate to navigate search sub-locations.
  /// NOTE: Create delegate outside build method in order to avoid state issues.
  static BeamerDelegate searchRouterDelegate = BeamerDelegate(
    initialPath: SearchContentLocation.route,
    locationBuilder: BeamerLocationBuilder(beamLocations: [
      SearchContentLocation(
        BeamState.fromUriString(SearchContentLocation.route),
      ),
    ]),
  );

  /// Beamer key to navigate dashboard sub-locations.
  static GlobalKey<BeamerState> dashboardBeamerKey = GlobalKey<BeamerState>(
    debugLabel: "dashboard",
  );

  /// Beamer delegate to navigate dashboard sub-locations.
  /// NOTE: Create delegate outside build method in order to avoid state issues.
  static BeamerDelegate dashboardRouterDelegate = BeamerDelegate(
    initialPath: DashboardContentLocation.route,
    locationBuilder: BeamerLocationBuilder(beamLocations: [
      DashboardContentLocation(
        BeamState.fromUriString(DashboardContentLocation.route),
      ),
    ]),
  );
}
