import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/push_notifications.dart';
import 'package:memorare/screens/dashboard.dart';
import 'package:memorare/screens/discover.dart';
import 'package:memorare/screens/topics.dart';
import 'package:memorare/state/colors.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
    int _selectedIndex = 0;

  static List<Widget> _listScreens = <Widget>[
    Discover(),
    Topics(),
    Dashboard(),
  ];

  @override
  void initState() {
    super.initState();
    // AppNotifications.initialize(context: context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: Provider.of<HttpClientsModel>(context).defaultClient,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Out Of Context',
        theme: stateColors.themeData,
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                child: _listScreens.elementAt(_selectedIndex),
              ),
              PushNotifications(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline,),
                title: Text('Discover',),
              ),
              BottomNavigationBarItem(
                icon: Icon(IconsMore.tags,),
                title: Text('Topics',),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.perm_identity,),
                title: Text('Account',),
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: stateColors.primary,
            unselectedItemColor: stateColors.foreground,
          ),
        ),
      ),
    );
  }
}
