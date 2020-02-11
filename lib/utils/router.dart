import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/screens/web/about.dart';
import 'package:memorare/screens/web/author_page.dart';
import 'package:memorare/screens/web/contact.dart';
import 'package:memorare/screens/web/home.dart';
import 'package:memorare/screens/web/privacy_terms.dart';
import 'package:memorare/screens/web/quote_page.dart';
import 'package:memorare/screens/web/reference_page.dart';
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

  static Handler _homehandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Home()));

  static Handler _privacyhandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(PrivacyTerms()));

  static Handler _quotePagehandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(QuotePage(quoteId: params['id'][0],)));

  static Handler _referencehandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(ReferencePage(id: params['id'][0])));

  static Handler _topichandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(TopicPage(name: params['name'][0])));

  static Handler _undefinedhandler = Handler(
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
      HomeRoute,
      handler: _homehandler,
    );
    router.define(
      PrivacyRoute,
      handler: _privacyhandler,
    );
    router.define(
      QuotePageRoute,
      handler: _quotePagehandler,
    );
    router.define(
      ReferenceRoute,
      handler: _referencehandler,
    );
    router.define(
      TopicRoute,
      handler: _topichandler,
    );
    router.define(
      UndefinedRoute,
      handler: _undefinedhandler,
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
