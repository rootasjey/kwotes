import "package:beamer/beamer.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/router/locations/home_location.dart";

class Passage {
  const Passage();

  /// Better navigate back to the previous page.
  /// Takes care of the following cases:
  /// - There's no history but we're not on home page -> back to home.
  void back(BuildContext context, {bool isMobile = false}) {
    // if (isMobile) {
    //   final bool handled = handleMobileBack(context);

    //   if (handled) {
    //     return;
    //   }
    // }

    if (Beamer.of(context).canBeamBack) {
      Beamer.of(context).beamBack();
      return;
    }

    final history = Beamer.of(context).beamingHistory;
    final String stringLocation =
        history.last.state.routeInformation.uri.toString();
    final RegExp slashRegex = RegExp(r"(/)");
    final slashMatches = slashRegex.allMatches(stringLocation);

    if (history.length == 1 && slashMatches.length == 1) {
      Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
      return;
    }

    Beamer.of(context).popRoute();
  }

  void deepBack(BuildContext context) {
    final BeamerDelegate beamer = Beamer.of(context);

    if (beamer.canBeamBack) {
      beamer.beamBack();
      return;
    }

    if (beamer.canPopBeamLocation) {
      beamer.popBeamLocation();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  /// Return hero tag stored as a string from `routeState` map if any.
  String getHeroTag(Object? routeState) {
    if (routeState == null) {
      return "";
    }

    final mapState = routeState as Map<String, dynamic>;
    return mapState["heroTag"] ?? "";
  }

  bool handleMobileBack(BuildContext context) {
    final String location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .uri
        .toString();

    final bool containsAtelier = location.contains("atelier");
    final List<String> locationParts = location.split("/");
    final bool threeDepths = locationParts.length == 3;
    if (!threeDepths) {
      return false;
    }

    final bool atelierIsSecond = locationParts.elementAt(1) == "atelier";

    if (containsAtelier && threeDepths && atelierIsSecond) {
      Beamer.of(context, root: true)
          .beamToNamed(HomeLocation.route, routeState: {
        "initialTabIndex": 2,
      });
      return true;
    }

    return false;
  }
}
