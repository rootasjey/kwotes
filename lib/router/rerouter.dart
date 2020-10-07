import 'package:flutter/material.dart';

import 'package:memorare/router/route_names.dart';
import 'package:memorare/screens/account.dart';
import 'package:memorare/screens/add_quote/steps.dart';
import 'package:memorare/screens/admin_quotes.dart';
import 'package:memorare/screens/admin_temp_quotes.dart';
import 'package:memorare/screens/drafts.dart';
import 'package:memorare/screens/home/home.dart';
import 'package:memorare/screens/published_quotes.dart';
import 'package:memorare/screens/quotes_lists.dart';
import 'package:memorare/screens/search.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/signup.dart';
import 'package:memorare/screens/temp_quotes.dart';
import 'package:memorare/screens/web/favourites.dart';

class Rerouter {
  static void push({
    @required BuildContext context,
    @required String value,
  }) {
    switch (value) {
      case AccountRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Account()),
        );
        break;
      case AddQuoteContentRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddQuoteSteps()),
        );
        break;
      case AdminTempQuotesRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AdminTempQuotes()),
        );
        break;
      case QuotesRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AdminQuotes()),
        );
        break;
      case DraftsRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Drafts()),
        );
        break;
      case FavouritesRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Favourites()),
        );
        break;
      case HomeRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Home()),
        );
        break;
      case ListsRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => QuotesLists()),
        );
        break;
      case PublishedQuotesRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MyPublishedQuotes()),
        );
        break;
      case RootRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Home()),
        );
        break;
      case SearchRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Search()),
        );
        break;
      case SigninRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Signin()),
        );
        break;
      case SignupRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Signup()),
        );
        break;
      case TempQuotesRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MyTempQuotes()),
        );
        break;
      default:
        break;
    }
  }
}
