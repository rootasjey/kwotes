import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/all_topics.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/full_page_quotidian.dart';
import 'package:memorare/screens/home.dart';
import 'package:memorare/screens/quote_page.dart';
import 'package:memorare/screens/reference_page.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/signup.dart';
import 'package:memorare/screens/topic_page.dart';

class MobileRouteHandlers {
  static Handler author = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AuthorPage(id: params['id'][0]));

  static Handler home = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home());

  static Handler quote = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotePage(id: params['id'][0]));

  static Handler quotidian = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          FullPageQuotidian());

  static Handler reference = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ReferencePage(id: params['id'][0]));

  static Handler signin = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signin());

  static Handler signup = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signup());

  static Handler topic = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TopicPage(name: params['name'][0]));

  static Handler topics = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AllTopics());
}
