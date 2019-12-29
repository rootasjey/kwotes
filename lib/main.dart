import 'dart:async';
import 'dart:convert';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/account.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/screens/discover.dart';
import 'package:memorare/screens/quotidians.dart';
import 'package:memorare/screens/topics.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  AppState createState() => AppState();
}

class AppState extends State<App> {
  Map<String, dynamic> _apiConfig;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> getApiConfig() async {
    var jsonFile = await DefaultAssetBundle.of(context)
      .loadString('assets/api.json');

    Map<String, dynamic> apiConfig = jsonDecode(jsonFile);
    return apiConfig;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserDataModel>(create: (context) => UserDataModel(),),
        ChangeNotifierProvider<HttpClientsModel>(create: (context) => HttpClientsModel(apiConfig: _apiConfig),),
        ChangeNotifierProvider<ThemeColor>(create: (context) => ThemeColor(),),
      ],
      child: DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
          fontFamily: 'Comfortaa',
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          return Main(theme: theme,);
        },
      ),
    );
  }
}

class Main extends StatefulWidget {
  final ThemeData theme;

  Main({this.theme});

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
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

    getApiConfig()
      .then((apiConfig) {
        setState(() {
          Provider.of<HttpClientsModel>(context).setApiConfig(apiConfig);
        });

        final userDataModel = Provider.of<UserDataModel>(context);
        userDataModel.readFromFile()
          .then((_) {
            Provider.of<HttpClientsModel>(context)
              .setToken(
                token: userDataModel.data.token,
                context: context
              );
          })
          .then((_) {
            Queries.todayTopic(context)
              .then((topic) {
                Provider.of<ThemeColor>(context).updatePalette(context, topic);
              });
          });
      });
  }

  Future<Map<String, dynamic>> getApiConfig() async {
    var jsonFile = await DefaultAssetBundle.of(context)
      .loadString('assets/api.json');

    Map<String, dynamic> apiConfig = jsonDecode(jsonFile);
    return apiConfig;
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
        title: 'Memorare',
        theme: widget.theme,
        home: Scaffold(
          body: Container(
            child: _listScreens.elementAt(_selectedIndex),
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
