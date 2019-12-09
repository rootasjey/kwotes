import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/screens/account.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/screens/quotidians.dart';
import 'package:memorare/screens/random_quotes.dart';
import 'package:memorare/screens/recent_quotes.dart';
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
      ],
      child: Main(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  int _selectedIndex = 0;

  static List<Widget> _listScreens = <Widget>[
    Quotidians(),
    RecentQuotes(),
    RandomQuotes(),
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
              .setToken(userDataModel.data.token);
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
    return GraphQLProvider(
      client: Provider.of<HttpClientsModel>(context).defaultClient,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Memorare',
        theme: ThemeData(
          fontFamily: 'Comfortaa',
          primarySwatch: MaterialColor(0xFF706FD2, accentSwatchColor),
        ),
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
                icon: Icon(Icons.list,),
                title: Text('Recent',),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.format_quote,),
                title: Text('Random',),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.perm_identity,),
                title: Text('Account',),
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: ThemeColor.primary,
            unselectedItemColor: Colors.black54,
          ),
        ),
      ),
    );
  }
}

Map<int, Color> accentSwatchColor = {
  50: Color.fromRGBO(112, 111, 210, .1),
  100: Color.fromRGBO(112, 111, 210, .2),
  200: Color.fromRGBO(112, 111, 210, .3),
  300: Color.fromRGBO(112, 111, 210, .4),
  400: Color.fromRGBO(112, 111, 210, .5),
  500: Color.fromRGBO(112, 111, 210, .6),
  600: Color.fromRGBO(112, 111, 210, .7),
  700: Color.fromRGBO(112, 111, 210, .8),
  800: Color.fromRGBO(112, 111, 210, .9),
  900: Color.fromRGBO(112, 111, 210, 1),
};
