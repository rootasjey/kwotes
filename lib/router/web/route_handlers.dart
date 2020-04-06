import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/all_topics.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/screens/web/about.dart';
import 'package:memorare/screens/web/account.dart';
import 'package:memorare/screens/web/add_quote_author.dart';
import 'package:memorare/screens/web/add_quote_comment.dart';
import 'package:memorare/screens/web/add_quote_content.dart';
import 'package:memorare/screens/web/add_quote_reference.dart';
import 'package:memorare/screens/web/add_quote_topics.dart';
import 'package:memorare/screens/web/admin_temp_quotes.dart';
import 'package:memorare/screens/web/author_page.dart';
import 'package:memorare/screens/web/contact.dart';
import 'package:memorare/screens/web/dashboard.dart';
import 'package:memorare/screens/web/delete_account.dart';
import 'package:memorare/screens/web/edit_email.dart';
import 'package:memorare/screens/web/edit_password.dart';
import 'package:memorare/screens/web/favourites.dart';
import 'package:memorare/screens/web/home.dart';
import 'package:memorare/screens/web/privacy_terms.dart';
import 'package:memorare/screens/web/published_quotes.dart';
import 'package:memorare/screens/web/quote_page.dart';
import 'package:memorare/screens/web/admin_quotes.dart';
import 'package:memorare/screens/web/quotes_list.dart';
import 'package:memorare/screens/web/quotes_lists.dart';
import 'package:memorare/screens/web/quotidians.dart';
import 'package:memorare/screens/web/reference_page.dart';
import 'package:memorare/screens/web/signin.dart';
import 'package:memorare/screens/web/signup.dart';
import 'package:memorare/screens/web/temp_quotes.dart';
import 'package:memorare/screens/web/topic_page.dart';
import 'package:memorare/screens/web/undefined_page.dart';

class WebRouteHandlers {
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

  static Handler aboutHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(About()));

  static Handler accountHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Account()));

  static Handler addQuoteHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteContent());

  static Handler addQuoteAuthorHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteAuthor());

  static Handler addQuoteCommentHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteComment());

  static Handler addQuoteReferenceHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteReference());

  static Handler addQuoteTopicsHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteTopics());

  static Handler adminTempQuotesHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AdminTempQuotes());

  static Handler authorHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(AuthorPage(id: params['id'][0],)));

  static Handler contactHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Contact()));

  static Handler dashboardHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Dashboard()));

  static Handler deleteAccountHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(DeleteAccount()));

  static Handler editEmailHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(EditEmail()));

  static Handler editPasswordHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(EditPassword()));

  static Handler favouritesHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Favourites());

  static Handler homeHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home());

  static Handler listHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotesList(listId: params['id'][0],));

  static Handler listsHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          QuotesLists());

  static Handler privacyHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(PrivacyTerms()));

  static Handler publishedQuotesHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          PublishedQuotes());

  static Handler quotePageHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(QuotePage(quoteId: params['id'][0],)));

  static Handler quotesPageHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AdminQuotes());

  static Handler quotidiansHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Quotidians());

  static Handler referenceHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(ReferencePage(id: params['id'][0])));

  static Handler signinHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Signin()));

  static Handler signupHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Signup()));

  static Handler topicHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TopicPage(name: params['name'][0]));

  static Handler topicsHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AllTopics());

  static Handler tempQuotesHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TempQuotes());

  static Handler undefinedHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(UndefinedPage(name: params['route'][0],)));
}
