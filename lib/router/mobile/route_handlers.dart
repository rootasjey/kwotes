import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/full_page_quotidian.dart';
import 'package:memorare/screens/home.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/signup.dart';

class MobileRouteHandlers {
  static Handler authorHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AuthorPage(id: params['id'][0]));

  static Handler homeHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home());

  static Handler quotidianHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          FullPageQuotidian());

  static Handler signinHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signin());

  static Handler signupHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signup());
}
