import 'package:fluro/fluro.dart';
import 'package:memorare/router/mobile/route_handlers.dart';
import 'package:memorare/router/web/route_handlers.dart';
import 'package:memorare/router/route_names.dart';

class FluroRouter {
  static Router router = Router();

  static void setupMobileRouter() {
    router.define(
      AuthorRoute,
      handler: MobileRouteHandlers.authorHandler,
    );

    router.define(
      HomeRoute,
      handler: MobileRouteHandlers.homeHandler,
    );

    router.define(
      RootRoute,
      handler: MobileRouteHandlers.quotidianHandler,
    );

    router.define(
      SigninRoute,
      handler: MobileRouteHandlers.signinHandler,
    );

    router.define(
      SignupRoute,
      handler: MobileRouteHandlers.signupHandler,
    );
  }

  static void setupWebRouter() {
    router.define(
      AboutRoute,
      handler: WebRouteHandlers.aboutHandler,
    );

    router.define(
      AccountRoute,
      handler: WebRouteHandlers.accountHandler,
    );

    router.define(
      AddQuoteContentRoute,
      handler: WebRouteHandlers.addQuoteHandler,
    );

    router.define(
      AddQuoteAuthorRoute,
      handler: WebRouteHandlers.addQuoteAuthorHandler,
    );

    router.define(
      AddQuoteCommentRoute,
      handler: WebRouteHandlers.addQuoteCommentHandler,
    );

    router.define(
      AddQuoteReferenceRoute,
      handler: WebRouteHandlers.addQuoteReferenceHandler,
    );

    router.define(
      AddQuoteTopicsRoute,
      handler: WebRouteHandlers.addQuoteTopicsHandler,
    );

    router.define(
      AdminTempQuotesRoute,
      handler: WebRouteHandlers.adminTempQuotesHandler,
    );

    router.define(
      AuthorRoute,
      handler: WebRouteHandlers.authorHandler,
    );

    router.define(
      ContactRoute,
      handler: WebRouteHandlers.contactHandler,
    );

    router.define(
      DashboardRoute,
      handler: WebRouteHandlers.dashboardHandler,
    );

    router.define(
      DeleteAccountRoute,
      handler: WebRouteHandlers.deleteAccountHandler,
    );

    router.define(
      EditEmailRoute,
      handler: WebRouteHandlers.editEmailHandler,
    );

    router.define(
      EditPasswordRoute,
      handler: WebRouteHandlers.editPasswordHandler,
    );

    router.define(
      FavouritesRoute,
      handler: WebRouteHandlers.favouritesHandler,
    );

    router.define(
      RootRoute,
      handler: WebRouteHandlers.homeHandler,
    );

    router.define(
      ListRoute,
      handler: WebRouteHandlers.listHandler,
    );

    router.define(
      ListsRoute,
      handler: WebRouteHandlers.listsHandler,
    );

    router.define(
      PrivacyRoute,
      handler: WebRouteHandlers.privacyHandler,
    );

    router.define(
      PublishedQuotesRoute,
      handler: WebRouteHandlers.publishedQuotesHandler,
    );

    router.define(
      QuotePageRoute,
      handler: WebRouteHandlers.quotePageHandler,
    );

    router.define(
      QuotesRoute,
      handler: WebRouteHandlers.quotesPageHandler,
    );

    router.define(
      QuotidiansRoute,
      handler: WebRouteHandlers.quotidiansHandler,
    );

    router.define(
      ReferenceRoute,
      handler: WebRouteHandlers.referenceHandler,
    );

    router.define(
      SigninRoute,
      handler: WebRouteHandlers.signinHandler,
    );

    router.define(
      SignupRoute,
      handler: WebRouteHandlers.signupHandler,
    );

    router.define(
      TempQuotesRoute,
      handler: WebRouteHandlers.tempQuotesHandler,
    );

    router.define(
      TopicRoute,
      handler: WebRouteHandlers.topicHandler,
    );

    router.define(
      TopicsRoute,
      handler: WebRouteHandlers.topicsHandler,
    );

    router.define(
      UndefinedRoute,
      handler: WebRouteHandlers.undefinedHandler,
    );
  }
}
