import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/screens/color_palette/color_palette_page.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page.dart";
import "package:kwotes/screens/settings/about/changelog_page.dart";
import "package:kwotes/screens/settings/about/credits_page.dart";
import "package:kwotes/screens/settings/about/feedback/feedback_page.dart";
import "package:kwotes/screens/settings/about/terms_of_service_page.dart";
import "package:kwotes/screens/settings/about/about_us_page.dart";
import "package:kwotes/screens/settings/account/account_page.dart";
import "package:kwotes/screens/settings/delete_account/delete_account_page.dart";
import "package:kwotes/screens/settings/email/update_email_page.dart";
import "package:kwotes/screens/settings/frame_border_style_page.dart";
import "package:kwotes/screens/settings/language_page.dart";
import "package:kwotes/screens/settings/password/update_password_page.dart";
import "package:kwotes/screens/settings/premium/subscriptions_page.dart";
import "package:kwotes/screens/settings/settings_page.dart";
import "package:kwotes/screens/settings/theme_page.dart";
import "package:kwotes/screens/settings/user_interface_page.dart";
import "package:kwotes/screens/settings/username/update_username_page.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";

class SettingsLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/settings";
  static const String routeWildCard = "/settings/*";

  @override
  List<String> get pathPatterns => [
        route,
        routeWildCard,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const SettingsPage(
          selfPageShortcutsActive: true,
        ),
        key: const ValueKey(route),
        title: "page_title.settings".tr(),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}

class SettingsContentLocation extends BeamLocation<BeamState> {
  SettingsContentLocation(BeamState? beamState)
      : super(beamState?.routeInformation);

  /// Main root value for this location.
  static const String route = "/settings";

  /// Account route location.
  static const String accountRoute = "$route/account";

  /// Forgot password route location.
  static const String forgotPasswordRoute = "$accountRoute/forgot-password";

  /// About route location.
  static const String aboutRoute = "$route/about";

  /// Changelog route location.
  static const String changelogRoute = "$aboutRoute/changelog";

  /// Frame border style route location.
  static const String frameBorderStyleRoute =
      "$userInterfaceRoute/frame-border-style";

  /// Theme route location.
  static const String themeRoute = "$route/theme";

  /// Language route location.
  static const String languageRoute = "$route/language";

  /// Terms of service route location.
  static const String tosRoute = "$aboutRoute/terms-of-service";

  /// Credits route location.
  static const String creditsRoute = "$aboutRoute/credits";

  /// The purpose route location.
  static const String aboutUsRoute = "$aboutRoute/the-purpose";

  /// Feedback route location.
  static const String feedbackRoute = "$aboutRoute/feedback";

  /// Color palette route location.
  static const String colorPaletteRoute = "$route/color-palette";

  /// User interface route location.
  static const String userInterfaceRoute = "$route/user-interface";

  /// Delete account route location.
  static const String deleteAccountRoute = "$accountRoute/delete-account";

  /// Update email route location.
  static const String updateEmailRoute = "$accountRoute/email";

  /// Update password route location.
  static const String updatePasswordRoute = "$accountRoute/password";

  /// Update username route location.
  static const String updateUsernameRoute = "$accountRoute/username";

  /// Subscriptions route
  static const String subscriptionsRoute = "$route/subscriptions";

  @override
  List<String> get pathPatterns => [
        aboutRoute,
        accountRoute,
        changelogRoute,
        colorPaletteRoute,
        creditsRoute,
        languageRoute,
        feedbackRoute,
        forgotPasswordRoute,
        frameBorderStyleRoute,
        route,
        tosRoute,
        themeRoute,
        aboutUsRoute,
        deleteAccountRoute,
        userInterfaceRoute,
        updateEmailRoute,
        updatePasswordRoute,
        updateUsernameRoute,
        subscriptionsRoute,
      ];

  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathPatterns: [accountRoute],
          beamToNamed: (origin, target) => SigninLocation.route,
          check: (BuildContext context, location) {
            final Signal<UserFirestore> currentUser =
                context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);
            return currentUser.value.id.isNotEmpty;
          },
        ),
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const SettingsPage(
          selfPageShortcutsActive: false,
        ),
        key: const ValueKey(route),
        title: "page_title.settings".tr(),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains(themeRoute.split("/").last))
        BeamPage(
          child: const ThemePage(),
          key: const ValueKey(themeRoute),
          title: "page_title.theme".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments.contains(languageRoute.split("/").last))
        BeamPage(
          child: const LanguagePage(),
          key: const ValueKey(languageRoute),
          title: "page_title.language".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments
          .contains(userInterfaceRoute.split("/").last))
        BeamPage(
          child: const UserInterfacePage(),
          key: const ValueKey(userInterfaceRoute),
          title: "page_title.user_interface".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments
          .contains(frameBorderStyleRoute.split("/").last))
        BeamPage(
          child: const FrameBorderStylePage(),
          key: const ValueKey(frameBorderStyleRoute),
          title: "page_title.frame_border_style".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments.contains(colorPaletteRoute.split("/").last))
        BeamPage(
          child: const ColorPalettePage(),
          key: const ValueKey(colorPaletteRoute),
          title: "page_title.about".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments.contains(route.split("/").last) &&
          state.pathPatternSegments.contains(tosRoute.split("/").last))
        BeamPage(
          child: const TermsOfServicePage(),
          key: const ValueKey(tosRoute),
          title: "page_title.terms_of_service".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments.contains(creditsRoute.split("/").last))
        BeamPage(
          child: const CreditsPage(),
          key: const ValueKey(creditsRoute),
          title: "page_title.credits".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments.contains(route.split("/").last) &&
          state.pathPatternSegments.contains(aboutUsRoute.split("/").last))
        BeamPage(
          child: const AboutUsPage(),
          key: const ValueKey(aboutUsRoute),
          title: "page_title.about".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments.contains(changelogRoute.split("/").last))
        BeamPage(
          child: const ChangelogPage(),
          key: const ValueKey(changelogRoute),
          title: "page_title.changelog".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments.contains(accountRoute.split("/").last))
        BeamPage(
          child: const AccountPage(),
          key: const ValueKey(accountRoute),
          title: "page_title.account".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments.contains(updateEmailRoute.split("/").last))
        BeamPage(
          child: const UpdateEmailPage(),
          key: const ValueKey(updateEmailRoute),
          title: "page_title.update_email".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments
          .contains(updatePasswordRoute.split("/").last))
        BeamPage(
          child: const UpdatePasswordPage(),
          key: const ValueKey(updatePasswordRoute),
          title: "page_title.update_password".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments
          .contains(updateUsernameRoute.split("/").last))
        BeamPage(
          child: const UpdateUsernamePage(),
          key: const ValueKey(updateUsernameRoute),
          title: "page_title.update_username".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments
          .contains(forgotPasswordRoute.split("/").last))
        BeamPage(
          child: const ForgotPasswordPage(),
          key: const ValueKey(forgotPasswordRoute),
          title: "page_title.forgot_password".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments.contains(feedbackRoute.split("/").last))
        BeamPage(
          child: const FeedbackPage(),
          key: const ValueKey(feedbackRoute),
          title: "page_title.contact_us".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments
          .contains(deleteAccountRoute.split("/").last))
        BeamPage(
          child: const DeleteAccountPage(),
          key: const ValueKey(deleteAccountRoute),
          title: "page_title.delete_account".tr(),
          type: BeamPageType.slideRightTransition,
        ),
      if (state.pathPatternSegments
          .contains(subscriptionsRoute.split("/").last))
        BeamPage(
          child: const SubscriptionsPage(),
          key: const ValueKey(subscriptionsRoute),
          title: "page_title.subscriptions".tr(),
          type: BeamPageType.slideRightTransition,
        ),
    ];
  }
}
