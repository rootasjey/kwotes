import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/all_topics.dart';
import 'package:memorare/screens/admin_quotes.dart';
import 'package:memorare/screens/author_page.dart';
import 'package:memorare/screens/drafts.dart';
import 'package:memorare/screens/edit_email.dart';
import 'package:memorare/screens/forgot_password.dart';
import 'package:memorare/screens/quotes_list.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/signup.dart';
import 'package:memorare/screens/web/about.dart';
import 'package:memorare/screens/web/account.dart';
import 'package:memorare/screens/web/add_quote_author.dart';
import 'package:memorare/screens/web/add_quote_comment.dart';
import 'package:memorare/screens/web/add_quote_content.dart';
import 'package:memorare/screens/web/add_quote_reference.dart';
import 'package:memorare/screens/web/add_quote_topics.dart';
import 'package:memorare/screens/web/admin_temp_quotes.dart';
import 'package:memorare/screens/web/contact.dart';
import 'package:memorare/screens/web/dashboard.dart';
import 'package:memorare/screens/web/delete_account.dart';
import 'package:memorare/screens/web/edit_password.dart';
import 'package:memorare/screens/web/favourites.dart';
import 'package:memorare/screens/web/home.dart';
import 'package:memorare/screens/web/privacy_terms.dart';
import 'package:memorare/screens/web/published_quotes.dart';
import 'package:memorare/screens/web/quote_page.dart';
import 'package:memorare/screens/web/quotes_lists.dart';
import 'package:memorare/screens/web/quotidians.dart';
import 'package:memorare/screens/web/reference_page.dart';
import 'package:memorare/screens/web/temp_quotes.dart';
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
          Account());

  static Handler addQuote = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteContent());

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
          AdminTempQuotes());

  static Handler author = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AuthorPage(id: params['id'][0],));

  static Handler contact = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Contact()));

  static Handler dashboard = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Dashboard()));

  static Handler deleteAccount = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(DeleteAccount()));

  static Handler drafts = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Drafts());

  static Handler editEmail = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          EditEmail());

  static Handler editPassword = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(EditPassword()));

  static Handler favourites = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Favourites());

  static Handler forgotPassword = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ForgotPassword());

  static Handler home = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home());

  static Handler list = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotesList(id: params['id'][0],));

  static Handler lists = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotesLists());

  static Handler privacy = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(PrivacyTerms()));

  static Handler publishedQuotes = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          PublishedQuotes());

  static Handler quotePage = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(QuotePage(quoteId: params['id'][0],)));

  static Handler quotesPage = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AdminQuotes());

  static Handler quotidians = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Quotidians());

  static Handler reference = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(ReferencePage(id: params['id'][0])));

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
          TempQuotes());

  static Handler undefined = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(UndefinedPage(name: params['route'][0],)));
}
