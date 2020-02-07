import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/screens/web/contact.dart';
import 'package:memorare/screens/web/home.dart';
import 'package:memorare/screens/web/undefined_page.dart';
import 'package:memorare/utils/route_names.dart';

class FluroRouter {
  static Router router = Router();

  static Handler _contactHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Contact()));

  static Handler _homehandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Home()));

  static Handler _undefinedhandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(UndefinedPage(name: params['route'][0],)));

  static void setupRouter() {
    router.define(
      HomeRoute,
      handler: _homehandler,
    );
    router.define(
      ContactRoute,
      handler: _contactHandler,
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
