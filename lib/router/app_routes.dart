import "package:beamer/beamer.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/forgot_password_location.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/router/locations/search_location.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/router/locations/signup_location.dart";
import "package:kwotes/router/locations/home_location.dart";

/// Router delegate for the app.
final BeamerDelegate appBeamerDelegate = BeamerDelegate(
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(),
      DashboardLocation(),
      SearchLocation(),
      ForgotPasswordLocation(),
      SettingsLocation(),
      SigninLocation(),
      SignupLocation(),
    ],
  ),
);
