import "package:beamer/beamer.dart";
import "package:kwotes/router/locations/forgot_password_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/router/locations/signup_location.dart";

/// Router delegate for the app.
final BeamerDelegate appBeamerDelegate = BeamerDelegate(
  initialPath: "/h",
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(),
      SigninLocation(),
      SignupLocation(),
      ForgotPasswordLocation(),
      SettingsLocation(),
    ],
  ),
);
