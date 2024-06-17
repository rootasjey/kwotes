import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";
import "package:kwotes/types/user/user_firestore.dart";

class Passage {
  const Passage();

  /// Better navigate back to the previous page.
  /// Takes care of the following cases:
  /// - There's no history but we're not on home page -> back to home.
  void back(BuildContext context, {bool isMobile = false}) {
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

  /// Check if the user can add a quote.
  bool canAddQuote(BuildContext context) {
    final UserFirestore userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value;

    final bool hasReachFreeLimit = userFirestore.plan == EnumUserPlan.free &&
        userFirestore.metrics.quotes.created >= 5;

    if (!userFirestore.rights.canProposeQuote || hasReachFreeLimit) {
      if (Utils.graphic.isMobile()) {
        Beamer.of(context, root: true).beamToNamed(
          HomeLocation.premiumRoute,
        );
        return false;
      }

      Utils.graphic.showSnackbar(
        context,
        message: "premium.add_quote_reached_free_plan_limit".tr(args: ["5"]),
      );
      return false;
    }

    return true;
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

    Beamer.of(context, root: true).beamToNamed(beamer.initialPath);
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
