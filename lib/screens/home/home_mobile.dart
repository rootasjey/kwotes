import 'dart:async';

import 'package:figstyle/screens/quote_page.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/utils/icons_more_icons.dart';
import 'package:figstyle/screens/dashboard.dart';
import 'package:figstyle/screens/discover.dart';
import 'package:figstyle/screens/recent_quotes.dart';
import 'package:figstyle/screens/search.dart';
import 'package:figstyle/screens/topics.dart';
import 'package:figstyle/state/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomeMobile extends StatefulWidget {
  final int initialIndex;

  HomeMobile({
    this.initialIndex = 0,
  });

  @override
  _HomeMobileState createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  int selectedIndex = 0;

  static List<Widget> _listScreens = <Widget>[
    RecentQuotes(
      showNavBackIcon: false,
    ),
    Search(),
    Discover(),
    Topics(),
    Dashboard(),
  ];

  @override
  void initState() {
    super.initState();

    setState(() {
      selectedIndex = widget.initialIndex;
    });

    openQuoteIfNotification();
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _listScreens.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.timelapse,
            ),
            label: 'Recent',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.lightbulb_outline,
            ),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconsMore.tags,
            ),
            label: 'Topics',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.perm_identity,
            ),
            label: 'Account',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: stateColors.primary,
        unselectedItemColor: stateColors.foreground,
      ),
    );
  }

  void openQuoteIfNotification() {
    final val = appStorage.getString(StorageKeys.quoteIdNotification) ?? '';

    if (val.isNotEmpty) {
      Timer(
        Duration(seconds: 2), // Error if fired too fast
        () {
          appStorage.setString(StorageKeys.quoteIdNotification, '');

          showCupertinoModalBottomSheet(
            context: context,
            builder: (context, scrollController) => QuotePage(
              padding: const EdgeInsets.only(left: 10.0),
              quoteId: val,
              scrollController: scrollController,
            ),
          );
        },
      );
    }
  }
}
