import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/screens/dashboard.dart';
import 'package:memorare/screens/discover.dart';
import 'package:memorare/screens/recent_quotes.dart';
import 'package:memorare/screens/search.dart';
import 'package:memorare/screens/topics.dart';
import 'package:memorare/state/colors.dart';

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
      // selectedIndex = widget.initialIndex;
      selectedIndex = 4;
    });
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
}
