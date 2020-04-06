import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/app_notifications.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/push_notifications.dart';
import 'package:memorare/screens/account.dart';
import 'package:memorare/screens/discover.dart';
import 'package:memorare/screens/quotidians.dart';
import 'package:memorare/screens/topics.dart';
import 'package:memorare/types/app_settings.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final ThemeData theme;

  Home({this.theme});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
    int _selectedIndex = 0;

  static List<Widget> _listScreens = <Widget>[
    Quotidians(),
    Discover(),
    Topics(),
    Account(),
  ];

  @override
  void initState() {
    super.initState();

    final userDataModel = Provider.of<UserDataModel>(context, listen: false);

    userDataModel.readFromFile()
    .then((_) {
      Provider.of<HttpClientsModel>(context, listen: false)
        .setToken(
          token: userDataModel.data.token,
          context: context
        );
    })
    .then((_) async {
      final themeColor = Provider.of<ThemeColor>(context, listen: false);
      themeColor.initializeBackgroundColor(context);

      final hasConnection = await DataConnectionChecker().hasConnection;
      if (!hasConnection) { return; }

      Queries.todayTopic(context)
        .then((topic) {
          themeColor.updatePalette(context, topic);
        });
    })
    .then((_) async {
      final hasConnection = await DataConnectionChecker().hasConnection;
      if (!hasConnection) { return; }

      if (userDataModel.data.id == null || userDataModel.data.id.isEmpty) {
        return;
      }

      userDataModel.fetchAndUpdate(context);
    })
    .then((_) {
      AppNotifications.initialize(context: context);

      AppSettings.readFromFile()
        .then((_) {
          if (AppSettings.isFirstLaunch) {
            AppSettings.updateFirstLaunch(false);
          }
        });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeColor>(context);

    return GraphQLProvider(
      client: Provider.of<HttpClientsModel>(context).defaultClient,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Out Of Context',
        theme: widget.theme,
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
                icon: Icon(Icons.wb_sunny,),
                title: Text('Today',),
              ),
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
            selectedItemColor: themeColor.accent,
            unselectedItemColor: themeColor.background,
          ),
        ),
      ),
    );
  }
}
