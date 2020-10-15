import 'package:flutter/material.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/screens/settings.dart';
import 'package:memorare/screens/recent_quotes.dart';
import 'package:memorare/screens/admin_temp_quotes.dart';
import 'package:memorare/screens/delete_account.dart';
import 'package:memorare/screens/drafts.dart';
import 'package:memorare/screens/update_email.dart';
import 'package:memorare/screens/update_password.dart';
import 'package:memorare/screens/published_quotes.dart';
import 'package:memorare/screens/quotes_list.dart';
import 'package:memorare/screens/quotes_lists.dart';
import 'package:memorare/screens/quotidians.dart';
import 'package:memorare/screens/temp_quotes.dart';
import 'package:memorare/screens/web/dashboard_section_template.dart';
import 'package:memorare/screens/web/favourites.dart';

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
    QuotesList(id: quoteListId), // doesn't get dynamic params
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
          ? QuotesList(id: widget.quoteListId)
          : _sections[_selectedIndex],
      childName: getSectionName(_selectedIndex),
      isNested: _selectedIndex == 5,
    );
  }

  String getSectionName(int index) {
    switch (index) {
      case 0:
        return FavouritesRoute;
      case 1:
        return ListsRoute;
      case 2:
        return DraftsRoute;
      case 3:
        return PublishedQuotesRoute;
      case 4:
        return TempQuotesRoute;
      case 5:
        return ListsRoute;
      case 6:
        return QuotesRoute;
      case 7:
        return AdminTempQuotesRoute;
      case 8:
        return QuotidiansRoute;
      case 9:
        return AccountRoute;
      case 10:
        return EditEmailRoute;
      case 11:
        return EditPasswordRoute;
      case 12:
        return DeleteAccountRoute;
      default:
        return FavouritesRoute;
    }
  }
}
