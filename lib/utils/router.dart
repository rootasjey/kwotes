import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/screens/web/about.dart';
import 'package:memorare/screens/web/author_page.dart';
import 'package:memorare/screens/web/contact.dart';
import 'package:memorare/screens/web/dashboard.dart';
import 'package:memorare/screens/web/home.dart';
import 'package:memorare/screens/web/privacy_terms.dart';
import 'package:memorare/screens/web/quote_page.dart';
import 'package:memorare/screens/web/reference_page.dart';
import 'package:memorare/screens/web/signin.dart';
import 'package:memorare/screens/web/signup.dart';
import 'package:memorare/screens/web/topic_page.dart';
import 'package:memorare/screens/web/undefined_page.dart';
import 'package:memorare/utils/route_names.dart';

class FluroRouter {
  static Router router = Router();

  static Handler _aboutHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(About()));

  static Handler _authorHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(AuthorPage(id: params['id'][0],)));

  static Handler _contactHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Contact()));

  static Handler _dashboardHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Dashboard()));

  static Handler _homeHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Home()));

  static Handler _privacyHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(PrivacyTerms()));

  static Handler _quotePageHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(QuotePage(quoteId: params['id'][0],)));

  static Handler _referenceHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(ReferencePage(id: params['id'][0])));

  static Handler _signinHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Signin()));

  static Handler _signupHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Signup()));

  static Handler _topicHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(TopicPage(name: params['name'][0])));

  static Handler _undefinedHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(UndefinedPage(name: params['route'][0],)));

  static void setupRouter() {
    router.define(
      AboutRoute,
      handler: _aboutHandler,
    );
    router.define(
      AuthorRoute,
      handler: _authorHandler,
    );
    router.define(
      ContactRoute,
      handler: _contactHandler,
    );
    router.define(
      DashboardRoute,
      handler: _dashboardHandler,
    );
    router.define(
      HomeRoute,
      handler: _homeHandler,
    );
    router.define(
      PrivacyRoute,
      handler: _privacyHandler,
    );
    router.define(
      QuotePageRoute,
      handler: _quotePageHandler,
    );
    router.define(
      ReferenceRoute,
      handler: _referenceHandler,
    );
    router.define(
      SigninRoute,
      handler: _signinHandler,
    );
    router.define(
      SignupRoute,
      handler: _signupHandler,
    );
    router.define(
      TopicRoute,
      handler: _topicHandler,
    );
    router.define(
      UndefinedRoute,
      handler: _undefinedHandler,
    );
  }

  static Widget _layout(Widget component) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          component,
          Footer(),
        ],
      ),
    );
  }
}
