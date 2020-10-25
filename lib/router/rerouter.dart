import 'package:flutter/material.dart';

import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/screens/settings.dart';
import 'package:figstyle/screens/add_quote/steps.dart';
import 'package:figstyle/screens/recent_quotes.dart';
import 'package:figstyle/screens/admin_temp_quotes.dart';
import 'package:figstyle/screens/drafts.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/screens/my_published_quotes.dart';
import 'package:figstyle/screens/quotes_lists.dart';
import 'package:figstyle/screens/search.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/screens/signup.dart';
import 'package:figstyle/screens/my_temp_quotes.dart';
import 'package:figstyle/screens/favourites.dart';

class Rerouter {
  static void push({
    @required BuildContext context,
    @required String value,
  }) {
    switch (value) {
      case AccountRoute:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Settings()),
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
          MaterialPageRoute(builder: (_) => RecentQuotes()),
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
