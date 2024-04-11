import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:kwotes/router/locations/forgot_password_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/router/locations/signup_location.dart";
import "package:kwotes/screens/not_found_page.dart";

/// Router delegate for the app.
final BeamerDelegate appBeamerDelegate = BeamerDelegate(
  initialPath: "/h",
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(),
      SigninLocation(),
      SignupLocation(),
      ForgotPasswordLocation(),
    ],
  ),
  notFoundPage: BeamPage(
    child: const NotFoundPage(),
    key: const ValueKey("notFoundPage"),
    type: BeamPageType.fadeTransition,
    title: "page_title.not_found".tr(),
  ),
);
