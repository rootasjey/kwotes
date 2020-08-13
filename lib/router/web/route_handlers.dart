import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/all_topics.dart';
import 'package:memorare/screens/add_quote/steps.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/authors.dart';
import 'package:memorare/screens/dashboard_sections.dart';
import 'package:memorare/screens/forgot_password.dart';
import 'package:memorare/screens/quotes_by_author_ref.dart';
import 'package:memorare/screens/reference_page.dart';
import 'package:memorare/screens/references.dart';
import 'package:memorare/screens/search.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/signup.dart';
import 'package:memorare/screens/web/about.dart';
import 'package:memorare/screens/add_quote/author.dart';
import 'package:memorare/screens/add_quote/comment.dart';
import 'package:memorare/screens/add_quote/reference.dart';
import 'package:memorare/screens/add_quote/topics.dart';
import 'package:memorare/screens/web/contact.dart';
import 'package:memorare/screens/web/dashboard.dart';
import 'package:memorare/screens/web/home.dart';
import 'package:memorare/screens/web/privacy_terms.dart';
import 'package:memorare/screens/web/quote_page.dart';
import 'package:memorare/screens/web/today.dart';
import 'package:memorare/screens/web/topic_page.dart';
import 'package:memorare/screens/web/undefined_page.dart';

class WebRouteHandlers {
  static Widget _layout(Widget component) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          component,
        ],
      ),
    );
  }

  static Handler about = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(About()));

  static Handler account = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 9,));

  static Handler addQuote = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteSteps());

  static Handler addQuoteAuthor = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteAuthor());

  static Handler addQuoteComment = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteComment());

  static Handler addQuoteReference = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteReference());

  static Handler addQuoteTopics = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteTopics());

  static Handler adminTempQuotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 7,));

  static Handler author = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AuthorPage(id: params['id'][0],));

  static Handler authors = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Authors());

  static Handler authorQuotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotesByAuthorRef(id: params['id'][0], type: SubjectType.author,));

  static Handler contact = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Contact()));

  static Handler dashboard = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Dashboard()));

  static Handler deleteAccount = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 12));

  static Handler drafts = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 2,));

  static Handler editEmail = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 10));

  static Handler editPassword = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 11));

  static Handler favourites = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections());

  static Handler forgotPassword = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ForgotPassword());

  static Handler home = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home());

  static Handler list = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 5, quoteListId: params['id'][0],)
          );

  static Handler lists = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 1,));

  static Handler privacy = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(PrivacyTerms()));

  static Handler publishedQuotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 3,));

  static Handler quotePage = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(QuotePage(quoteId: params['id'][0],)));

  static Handler quotesPage = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 6,));

  static Handler quotidians = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 8,));

  static Handler reference = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ReferencePage(id: params['id'][0]));

  static Handler references = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          References());

  static Handler referenceQuotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotesByAuthorRef(id: params['id'][0], type: SubjectType.reference,));

  static Handler search = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Search());

  static Handler signin = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signin());

  static Handler signup = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signup());

  static Handler today = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Today());

  static Handler topic = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TopicPage(name: params['name'][0]));

  static Handler topics = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AllTopics());

  static Handler tempQuotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DashboardSections(initialIndex: 4,));

  static Handler undefined = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(UndefinedPage(name: params['route'][0],)));

  static Handler welcomeBack = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home());
}
