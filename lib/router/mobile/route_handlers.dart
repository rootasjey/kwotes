import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/screens/full_page_quotidian.dart';
import 'package:memorare/screens/home.dart';

class MobileRouteHandlers {
  static Handler homeHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home());

  static Handler quotidianHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          FullPageQuotidian());
}
