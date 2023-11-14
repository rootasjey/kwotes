import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/screens/color_palette/color_detail_page.dart";
import "package:kwotes/screens/color_palette/color_palette_page.dart";
import "package:kwotes/screens/add_quote/add_quote_page.dart";
import "package:kwotes/screens/dashboard/dashboard_page.dart";
import "package:kwotes/screens/dashboard/dashboard_welcome_page.dart";
import "package:kwotes/screens/drafts/drafts_page.dart";
import "package:kwotes/screens/favourites/favourites_page.dart";
import "package:kwotes/screens/home/quote_page.dart";
import "package:kwotes/screens/in_validation/in_validation_page.dart";
import "package:kwotes/screens/list/list_page.dart";
import "package:kwotes/screens/lists/lists_page.dart";
import "package:kwotes/screens/published/published_page.dart";
import "package:kwotes/screens/settings/about/terms_of_service_page.dart";
import "package:kwotes/screens/settings/about/the_purpose_page.dart";
import "package:kwotes/screens/settings/delete_account/delete_account_page.dart";
import "package:kwotes/screens/settings/email/email_page.dart";
import "package:kwotes/screens/settings/password/password_page.dart";
import "package:kwotes/screens/settings/settings_page.dart";
import "package:kwotes/screens/settings/username/username_page.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";

class DashboardLocation extends BeamLocation<BeamState> {
  static const String route = "/dashboard";
  static const String routeWildCard = "/dashboard/*";

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
        )
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const DashboardPage(),
        key: const ValueKey(route),
        title: "page_title.dashboard".tr(),
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}

class DashboardContentLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = "/dashboard";

  /// Add quote route location.
  static const String addQuoteRoute = "$route/add-quote";
  static const String colorPaletteRoute = "$settingsRoute/color-palette";
  static const String colorDetailRoute = "$colorPaletteRoute/:topicName";
  static const String deleteAccountRoute = "$settingsRoute/delete-account";
  static const String draftsRoute = "$route/drafts";
  static const String favouritesRoute = "$route/favourites";
  static const String favouritesQuoteRoute = "$favouritesRoute/:quoteId";
  static const String inValidationRoute = "$route/in-validation";
  static const String listsRoute = "$route/lists";
  static const String listRoute = "$listsRoute/:listId";
  static const String listQuoteRoute = "$listRoute/quotes/:quoteId";
  static const String publishedRoute = "$route/published";
  static const String publishedQuoteRoute = "$publishedRoute/:quoteId";
  static const String settingsRoute = "$route/settings";
  static const String settingsTosRoute = "$settingsRoute/terms-of-service";
  static const String settingsThePurposeRoute = "$settingsRoute/the-purpose";
  static const String updateEmailRoute = "$settingsRoute/email";
  static const String updatePasswordRoute = "$settingsRoute/password";
  static const String updateUsernameRoute = "$settingsRoute/username";

  @override
  List<String> get pathPatterns => [
        addQuoteRoute,
        colorPaletteRoute,
        colorDetailRoute,
        deleteAccountRoute,
        draftsRoute,
        favouritesQuoteRoute,
        favouritesRoute,
        listQuoteRoute,
        listRoute,
        listsRoute,
        publishedRoute,
        inValidationRoute,
        settingsRoute,
        settingsTosRoute,
        settingsThePurposeRoute,
        publishedQuoteRoute,
        updateEmailRoute,
        updatePasswordRoute,
        updateUsernameRoute,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: const DashboardWelcomePage(),
        key: const ValueKey(route),
        title: "page_title.dashboard".tr(),
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
          child: const EmailPage(),
          key: const ValueKey(updateEmailRoute),
          title: "page_title.update_email".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last) &&
          state.pathPatternSegments
              .contains(updatePasswordRoute.split("/").last))
        BeamPage(
          child: const PasswordPage(),
          key: const ValueKey(updatePasswordRoute),
          title: "page_title.update_password".tr(),
          type: BeamPageType.fadeTransition,
        ),
      if (state.pathPatternSegments.contains(settingsRoute.split("/").last) &&
          state.pathPatternSegments
              .contains(updateUsernameRoute.split("/").last))
        BeamPage(
          child: const UsernamePage(),
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
      if (state.pathPatternSegments.contains(addQuoteRoute.split("/").last))
        BeamPage(
          child: const AddQuotePage(),
          key: const ValueKey(addQuoteRoute),
          title: "page_title.add_quote".tr(),
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
      if (state.pathPatternSegments.contains(":quoteId"))
        BeamPage(
          child: QuotePage(
            quoteId: state.pathParameters["quoteId"] ?? "",
          ),
          key: const ValueKey("quoteRoute"),
          title: "page_title.any".tr(),
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

  /// Extracts color's name from the route state.
  String extractTopicName(Object? routeState) {
    if (routeState == null) {
      return "";
    }

    final Map<String, dynamic> map = routeState as Map<String, dynamic>;
    return map["topicName"] ?? "";
  }
}
