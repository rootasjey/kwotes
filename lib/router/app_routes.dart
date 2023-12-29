import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:kwotes/router/locations/forgot_password_location.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/router/locations/signup_location.dart";
import "package:kwotes/screens/home/app_location_container.dart";

/// Router delegate for the app.
final BeamerDelegate appBeamerDelegate = BeamerDelegate(
  initialPath: "/h",
  locationBuilder: RoutesLocationBuilder(
    routes: {
      "/forgot-password":
          (BuildContext context, BeamState state, Object? data) =>
              ForgotPasswordLocation(),
      "/settings": (context, state, data) => SettingsLocation(),
      "/signin": (context, state, data) => SigninLocation(),
      "/signup": (context, state, data) => SignupLocation(),
      "*": (context, state, data) => const AppLocationContainer(),
    },
  ),
);
