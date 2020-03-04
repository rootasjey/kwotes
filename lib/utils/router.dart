import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
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
import 'package:memorare/screens/web/home.dart';
import 'package:memorare/screens/web/privacy_terms.dart';
import 'package:memorare/screens/web/quote_page.dart';
import 'package:memorare/screens/web/admin_quotes.dart';
import 'package:memorare/screens/web/quotidians.dart';
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

  static Handler _accountHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Account()));

  static Handler _addQuoteHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteContent());

  static Handler _addQuoteAuthorHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteAuthor());

  static Handler _addQuoteCommentHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteComment());

  static Handler _addQuoteReferenceHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteReference());

  static Handler _addQuoteTopicsHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddQuoteTopics());

  static Handler _adminTempQuotesHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(AdminTempQuotes()));

  static Handler _authorHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(AuthorPage(id: params['id'][0],)));

  static Handler _contactHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Contact()));

  static Handler _dashboardHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Dashboard()));

  static Handler _deleteAccountHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(DeleteAccount()));

  static Handler _editEmailHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(EditEmail()));

  static Handler _editPasswordHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(EditPassword()));

  static Handler _homeHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Home());

  static Handler _privacyHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(PrivacyTerms()));

  static Handler _quotePageHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(QuotePage(quoteId: params['id'][0],)));

  static Handler _quotesPageHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(AdminQuotes()));

  static Handler _quotidiansHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          _layout(Quotidians()));

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
      AccountRoute,
      handler: _accountHandler,
    );
    router.define(
      AddQuoteContentRoute,
      handler: _addQuoteHandler,
    );
    router.define(
      AddQuoteAuthorRoute,
      handler: _addQuoteAuthorHandler,
    );
    router.define(
      AddQuoteCommentRoute,
      handler: _addQuoteCommentHandler,
    );
    router.define(
      AddQuoteReferenceRoute,
      handler: _addQuoteReferenceHandler,
    );
    router.define(
      AddQuoteTopicsRoute,
      handler: _addQuoteTopicsHandler,
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
      DeleteAccountRoute,
      handler: _deleteAccountHandler,
    );
    router.define(
      EditEmailRoute,
      handler: _editEmailHandler,
    );
    router.define(
      EditPasswordRoute,
      handler: _editPasswordHandler,
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
      QuotesRoute,
      handler: _quotesPageHandler,
    );
    router.define(
      QuotidiansRoute,
      handler: _quotidiansHandler,
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
      AdminTempQuotesRoute,
      handler: _adminTempQuotesHandler,
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
