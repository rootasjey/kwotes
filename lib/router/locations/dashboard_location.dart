import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/screens/author/author_page.dart";
import "package:kwotes/screens/author/author_quotes_page.dart";
import "package:kwotes/screens/author/edit_author_page.dart";
import "package:kwotes/screens/color_palette/color_detail_page.dart";
import "package:kwotes/screens/color_palette/color_palette_page.dart";
import "package:kwotes/screens/add_quote/add_quote_page.dart";
import "package:kwotes/screens/dashboard/dashboard_navigation_page.dart";
import "package:kwotes/screens/dashboard/dashboard_welcome_page.dart";
import "package:kwotes/screens/drafts/drafts_page.dart";
import "package:kwotes/screens/favourites/favourites_page.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page.dart";
import "package:kwotes/screens/in_validation/in_validation_page.dart";
import "package:kwotes/screens/list/list_page.dart";
import "package:kwotes/screens/lists/lists_page.dart";
import "package:kwotes/screens/published/published_page.dart";
import "package:kwotes/screens/quote_page/quote_page.dart";
import "package:kwotes/screens/reference/edit_reference_page.dart";
import "package:kwotes/screens/reference/reference_page.dart";
import "package:kwotes/screens/reference/reference_quotes_page.dart";
import "package:kwotes/screens/settings/about/credits_page.dart";
import "package:kwotes/screens/settings/about/terms_of_service_page.dart";
import "package:kwotes/screens/settings/about/the_purpose_page.dart";
import "package:kwotes/screens/settings/delete_account/delete_account_page.dart";
import "package:kwotes/screens/settings/email/update_email_page.dart";
import "package:kwotes/screens/settings/password/update_password_page.dart";
import "package:kwotes/screens/settings/settings_page.dart";
import "package:kwotes/screens/settings/username/update_username_page.dart";
import "package:kwotes/screens/signin/signin_page.dart";
import "package:kwotes/screens/signup/signup_page.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";

class DashboardLocation extends BeamLocation<BeamState> {
  static const String route = "/d";
  static const String routeWildCard = "/d/*";

  @override
  List<String> get pathPatterns => [
        route,
        routeWildCard,
      ];

  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathPatterns: [route, routeWildCard],
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
        child: const DashboardNavigationPage(),
        key: const ValueKey(route),
        title: "page_title.dashboard".tr(),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}

class DashboardContentLocation extends BeamLocation<BeamState> {
  DashboardContentLocation(BeamState? beamState)
      : super(beamState?.routeInformation);

  /// Main root value for this location.
  static const String route = "/d";

  /// Forgot password route location.
  static const String forgotPasswordRoute = "$route/forgot-password";

  /// Add quote route location.
  static const String addQuoteRoute = "$route/add-quote";

  /// Author route location.
  static const String authorRoute = "$route/author/:authorId";

  /// Author's single quote route location.
  /// e.g. `/h/author/authorId/quotes/quoteId`
  /// Useful to keep previous author page(s) below this one.
  static const String authorQuoteRoute = "$authorRoute/quotes/:quoteId";

  /// Author's quotes route location.
  static const String authorQuotesRoute = "$authorRoute/quotes";

  static const String colorPaletteRoute = "$settingsRoute/color-palette";
  static const String colorDetailRoute = "$colorPaletteRoute/:topicName";
  static const String creditsRoute = "$settingsRoute/credits";
  static const String deleteAccountRoute = "$settingsRoute/delete-account";
  static const String draftsRoute = "$route/drafts";
  static const String editAuthorRoute = "$route/edit/author/:authorId";

  /// Add/edit quote route location.
  static const String editQuoteRoute = "$route/edit/quote/:quoteId";

  static const String editReferenceRoute = "$route/edit/reference/:referenceId";
  static const String favouritesRoute = "$route/favourites";
  static const String favouritesQuoteRoute = "$favouritesRoute/:quoteId";
  static const String inValidationRoute = "$route/in-validation";
  static const String listsRoute = "$route/lists";
  static const String listRoute = "$listsRoute/:listId";
  static const String listQuoteRoute = "$listRoute/quotes/:quoteId";
  static const String publishedRoute = "$route/published";
  static const String publishedQuoteRoute = "$publishedRoute/:quoteId";

  /// Reference route location.
  static const String referenceRoute = "$route/reference/:referenceId";

  /// Reference's quotes route location.
  static const String referenceQuotesRoute = "$referenceRoute/quotes";

  /// Reference's single quote route location.
  /// e.g. `/h/reference/authorId/quotes/quoteId`
  /// Useful to keep previous reference page(s) below this one.
  static const String referenceQuoteRoute = "$referenceRoute/quotes/:quoteId";

  static const String settingsRoute = "$route/settings";
  static const String settingsTosRoute = "$settingsRoute/terms-of-service";
  static const String settingsThePurposeRoute = "$settingsRoute/the-purpose";

  /// Signin route location.
  static const String signinRoute = "$route/signin";

  /// Signup route location.
  static const String signupRoute = "$route/signup";
  static const String updateEmailRoute = "$settingsRoute/email";
  static const String updatePasswordRoute = "$settingsRoute/password";
  static const String updateUsernameRoute = "$settingsRoute/username";

  @override
  List<String> get pathPatterns => [
        addQuoteRoute,
        authorRoute,
        authorQuoteRoute,
        authorQuotesRoute,
        colorPaletteRoute,
        colorDetailRoute,
        creditsRoute,
        deleteAccountRoute,
        draftsRoute,
        editAuthorRoute,
        editQuoteRoute,
        editReferenceRoute,
        favouritesQuoteRoute,
        favouritesRoute,
        listQuoteRoute,
        listRoute,
        listsRoute,
        publishedRoute,
        inValidationRoute,
        referenceRoute,
        referenceQuoteRoute,
        referenceQuotesRoute,
        settingsRoute,
        settingsTosRoute,
        settingsThePurposeRoute,
        signinRoute,
        signupRoute,
        forgotPasswordRoute,
        publishedQuoteRoute,
        updateEmailRoute,
        updatePasswordRoute,
        updateUsernameRoute,
      ];

  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathPatterns: [
            signinRoute,
            signupRoute,
            forgotPasswordRoute,
            settingsRoute,
            settingsTosRoute,
            settingsThePurposeRoute,
            colorPaletteRoute,
            colorDetailRoute,
            creditsRoute,
          ],
          guardNonMatching: true,
          beamToNamed: (origin, target) => signinRoute,
          check: (BuildContext context, location) {
            return Utils.state.userAuthenticated;
          },
        )
      ];

  @override
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const DashboardWelcomePage(),
        key: const ValueKey(route),
        title: "page_title.dashboard".tr(),
        type: BeamPageType.fadeTransition,
      ),
      if (state.pathPatternSegments.contains(signinRoute.split("/").last))
        BeamPage(
          child: const SigninPage(),
          key: const ValueKey(signinRoute),
          title: "page_title.signin".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(signupRoute.split("/").last))
        BeamPage(
          child: const SignupPage(),
          key: const ValueKey(signupRoute),
          title: "page_title.signup".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments
          .contains(forgotPasswordRoute.split("/").last))
        BeamPage(
          child: const ForgotPasswordPage(),
          key: const ValueKey(forgotPasswordRoute),
          title: "page_title.forgot_password".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(favouritesRoute.split("/").last))
        BeamPage(
          child: const FavouritesPage(),
          key: const ValueKey(favouritesRoute),
          title: "page_title.favourites".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(publishedRoute.split("/").last))
        BeamPage(
          child: const PublishedPage(),
          key: const ValueKey(publishedRoute),
          title: "page_title.published".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(inValidationRoute.split("/").last))
        BeamPage(
          child: const InValidationPage(),
          key: const ValueKey(inValidationRoute),
          title: "page_title.in_validation".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(draftsRoute.split("/").last))
        BeamPage(
          child: const DraftsPage(),
          key: const ValueKey(draftsRoute),
          title: "page_title.drafts".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(listsRoute.split("/").last))
        BeamPage(
          child: const ListsPage(),
          key: const ValueKey(listsRoute),
          title: "page_title.lists".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(listRoute.split("/").last))
        BeamPage(
          child: ListPage(
            listId: state.pathParameters["listId"] ?? "",
          ),
          key: const ValueKey(listRoute),
          title: "page_title.list".tr(args: [
            extractListName(state.routeState),
          ]),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last))
        BeamPage(
          child: const SettingsPage(),
          key: const ValueKey(settingsRoute),
          title: "page_title.settings".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last) &&
          state.pathPatternSegments.contains(updateEmailRoute.split("/").last))
        BeamPage(
          child: const UpdateEmailPage(),
          key: const ValueKey(updateEmailRoute),
          title: "page_title.update_email".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last) &&
          state.pathPatternSegments
              .contains(updatePasswordRoute.split("/").last))
        BeamPage(
          child: const UpdatePasswordPage(),
          key: const ValueKey(updatePasswordRoute),
          title: "page_title.update_password".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last) &&
          state.pathPatternSegments
              .contains(updateUsernameRoute.split("/").last))
        BeamPage(
          child: const UpdateUsernamePage(),
          key: const ValueKey(updateUsernameRoute),
          title: "page_title.update_username".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last) &&
          state.pathPatternSegments
              .contains(deleteAccountRoute.split("/").last))
        BeamPage(
          child: const DeleteAccountPage(),
          key: const ValueKey(deleteAccountRoute),
          title: "page_title.delete_account".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last) &&
          state.pathPatternSegments.contains(settingsTosRoute.split("/").last))
        BeamPage(
          child: const TermsOfServicePage(),
          key: const ValueKey(settingsTosRoute),
          title: "page_title.terms_of_service".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last) &&
          state.pathPatternSegments
              .contains(settingsThePurposeRoute.split("/").last))
        BeamPage(
          child: const ThePurposePage(),
          key: const ValueKey(settingsThePurposeRoute),
          title: "page_title.the_purpose".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last) &&
          state.pathPatternSegments.contains(creditsRoute.split("/").last))
        BeamPage(
          child: const CreditsPage(),
          key: const ValueKey(creditsRoute),
          title: "page_title.credits".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(addQuoteRoute.split("/").last))
        BeamPage(
          child: const AddQuotePage(),
          key: const ValueKey(addQuoteRoute),
          title: "page_title.add_quote".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains("edit") &&
          state.pathPatternSegments.contains(editQuoteRoute.split("/").last))
        BeamPage(
          child: AddQuotePage(
            quoteId: state.pathParameters["quoteId"] ?? "",
          ),
          key: const ValueKey(editQuoteRoute),
          title: "page_title.edit_quote".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(colorPaletteRoute.split("/").last))
        BeamPage(
          child: const ColorPalettePage(),
          key: const ValueKey(colorPaletteRoute),
          title: "page_title.color_palette".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(colorDetailRoute.split("/").last))
        BeamPage(
          child: ColorDetailPage(
            topicName: state.pathParameters["topicName"] ?? "",
          ),
          key: const ValueKey(colorDetailRoute),
          title: "page_title.color_detail".tr(
            args: [extractTopicName(state.routeState)],
          ),
          type: BeamPageType.fadeTransition,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains("edit") &&
          state.pathPatternSegments.contains(":authorId"))
        BeamPage(
          child: EditAuthorPage(
            authorId: state.pathParameters["authorId"] ?? "",
          ),
          key: const ValueKey(editAuthorRoute),
          title: "page_title.edit_author".tr(
            args: [extractAuthorName(state.routeState)],
          ),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains("edit") &&
          state.pathPatternSegments.contains(":referenceId"))
        BeamPage(
          child: EditReferencePage(
            referenceId: state.pathParameters["referenceId"] ?? "",
          ),
          key: const ValueKey(editReferenceRoute),
          title: "page_title.edit_reference".tr(
            args: [extractReferenceName(state.routeState)],
          ),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (!state.pathPatternSegments.contains("edit") &&
          state.pathPatternSegments.contains(authorRoute.split("/").last))
        BeamPage(
          child: AuthorPage(
            authorId: state.pathParameters["authorId"] ?? "",
          ),
          key: const ValueKey(authorRoute),
          title: "page_title.any".tr(
            args: [extractAuthorName(state.routeState)],
          ),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (!state.pathPatternSegments.contains("edit") &&
          state.pathPatternSegments.contains(referenceRoute.split("/").last))
        BeamPage(
          child: ReferencePage(
            referenceId: state.pathParameters["referenceId"] ?? "",
          ),
          key: const ValueKey(referenceRoute),
          title: "page_title.any".tr(
            args: [extractReferenceName(state.routeState)],
          ),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains(authorRoute.split("/").last) &&
          state.pathPatternSegments.contains(authorQuotesRoute.split("/").last))
        BeamPage(
          child: AuthorQuotesPage(
            authorId: state.pathParameters["authorId"] ?? "",
          ),
          key: const ValueKey(authorQuotesRoute),
          title: "page_title.author_quotes".tr(
            args: [extractAuthorName(state.routeState)],
          ),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains(referenceRoute.split("/").last) &&
          state.pathPatternSegments
              .contains(referenceQuotesRoute.split("/").last))
        BeamPage(
          child: ReferenceQuotesPage(
            referenceId: state.pathParameters["referenceId"] ?? "",
          ),
          key: const ValueKey(referenceQuotesRoute),
          title: "page_title.reference_quotes".tr(
            args: [extractReferenceName(state.routeState)],
          ),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
      if (state.pathPatternSegments.contains(":quoteId") &&
          !state.pathPatternSegments.contains("edit"))
        BeamPage(
          child: QuotePage(
            quoteId: state.pathParameters["quoteId"] ?? "",
          ),
          key: const ValueKey("quoteRoute"),
          title: getQuotePageTitle(state.routeState),
          type: BeamPageType.fadeTransition,
          fullScreenDialog: false,
          opaque: false,
        ),
    ];
  }

  /// Extracts the list's name from the route state.
  String extractListName(Object? routeState) {
    if (routeState == null) {
      return "";
    }

    final Map<String, dynamic> map = routeState as Map<String, dynamic>;
    return map["listName"] ?? "";
  }

  /// Extract author name from route state.
  String extractAuthorName(Object? routeState) {
    return routeState is Map ? routeState["authorName"] ?? "" : "";
  }

  /// Extract reference name from route state.
  String extractReferenceName(Object? routeState) {
    return routeState is Map ? routeState["referenceName"] ?? "" : "";
  }

  /// Extract topic name from route state.
  String extractTopicName(Object? routeState) {
    return routeState is Map ? routeState["topicName"] ?? "" : "";
  }

  /// Get quote page title from route state.
  String getQuotePageTitle(Object? routeState) {
    final String quoteName =
        routeState is Map ? routeState["quoteName"] ?? "" : "";

    if (quoteName.isEmpty) {
      return "page_title.quote".tr();
    }

    return "page_title.any".tr(
      args: [quoteName],
    );
  }
}
