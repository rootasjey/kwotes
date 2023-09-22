import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page.dart";

class ForgotPasswordLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/forgotpassword";

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const ForgotPasswordPage(),
        key: const ValueKey(route),
        title: "page_title.forgot_password".tr(),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
