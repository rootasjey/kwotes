import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/signin/signin_page.dart";

class SigninLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/signin";

  @override
  List<String> get pathPatterns => [route];

  /// Redirect to home ('/') if the user is authenticated.
  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathPatterns: [route],
          check: (context, location) {
            // final containerProvider = ProviderContainer();
            // final user = containerProvider.read(AppState.userProvider.notifier);
            // return !user.isAuthenticated;
            return true;
          },
          beamToNamed: (origin, target) => HomeLocation.route,
        ),
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const SigninPage(),
        key: const ValueKey(route),
        title: "page_title.signin".tr(),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
