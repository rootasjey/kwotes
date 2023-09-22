import "package:beamer/beamer.dart";
import "package:kwotes/router/locations/author_location.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/forgot_password_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/reference_location.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/router/locations/search_location.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/router/locations/signup_location.dart";
import "package:kwotes/router/locations/tos_location.dart";

final appLocationBuilder = BeamerDelegate(
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(),
      AuthorLocation(),
      ReferenceLocation(),
      DashboardLocation(),
      ForgotPasswordLocation(),
      SettingsLocation(),
      SearchLocation(),
      SigninLocation(),
      SignupLocation(),
      TosLocation(),
    ],
  ),
);
