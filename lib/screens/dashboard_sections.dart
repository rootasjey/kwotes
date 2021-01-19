import 'package:flutter/material.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/screens/settings.dart';
import 'package:figstyle/screens/recent_quotes.dart';
import 'package:figstyle/screens/admin_temp_quotes.dart';
import 'package:figstyle/screens/delete_account.dart';
import 'package:figstyle/screens/drafts.dart';
import 'package:figstyle/screens/update_email.dart';
import 'package:figstyle/screens/update_password.dart';
import 'package:figstyle/screens/my_published_quotes.dart';
import 'package:figstyle/screens/quotes_list.dart';
import 'package:figstyle/screens/quotes_lists.dart';
import 'package:figstyle/screens/quotidians.dart';
import 'package:figstyle/screens/my_temp_quotes.dart';
import 'package:figstyle/screens/dashboard_section_template.dart';
import 'package:figstyle/screens/favourites.dart';

class DashboardSections extends StatefulWidget {
  final int initialIndex;
  final String quoteListId;

  DashboardSections({
    this.initialIndex = 0,
    this.quoteListId = '',
  });

  @override
  _DashboardSectionsState createState() => _DashboardSectionsState();
}

class _DashboardSectionsState extends State<DashboardSections> {
  int _selectedIndex = 0;
  static String quoteListId = '';

  static List<Widget> _sections = <Widget>[
    Favourites(),
    QuotesLists(),
    Drafts(),
    MyPublishedQuotes(),
    MyTempQuotes(),
    QuotesList(listId: quoteListId), // doesn't get dynamic params
    RecentQuotes(),
    AdminTempQuotes(),
    Quotidians(),
    Settings(),
    UpdateEmail(),
    UpdatePassword(),
    DeleteAccount(),
  ];

  @override
  void initState() {
    super.initState();

    setState(() {
      _selectedIndex = widget.initialIndex;
    });
  }

  // ?NOTE:
  // This is a complex section until
  // there's a normal router with nested view.
  @override
  Widget build(BuildContext context) {
    return DashboardSectionTemplate(
      child: _selectedIndex == 5
          ? QuotesList(listId: widget.quoteListId)
          : _sections[_selectedIndex],
      childName: getSectionName(_selectedIndex),
      isNested: _selectedIndex == 5,
    );
  }

  String getSectionName(int index) {
    switch (index) {
      case 0:
        return RouteNames.FavouritesRoute;
      case 1:
        return RouteNames.ListsRoute;
      case 2:
        return RouteNames.DraftsRoute;
      case 3:
        return RouteNames.PublishedQuotesRoute;
      case 4:
        return RouteNames.TempQuotesRoute;
      case 5:
        return RouteNames.ListsRoute;
      case 6:
        return RouteNames.QuotesRoute;
      case 7:
        return RouteNames.AdminTempQuotesRoute;
      case 8:
        return RouteNames.QuotidiansRoute;
      case 9:
        return RouteNames.AccountRoute;
      case 10:
        return RouteNames.EditEmailRoute;
      case 11:
        return RouteNames.EditPasswordRoute;
      case 12:
        return RouteNames.DeleteAccountRoute;
      default:
        return RouteNames.FavouritesRoute;
    }
  }
}
