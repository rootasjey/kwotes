import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/screens/account.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/screens/quotidian.dart';
import 'package:memorare/screens/random_quote.dart';
import 'package:memorare/screens/recent.dart';
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
  @override
  void initState() {
    super.initState();

    getApiConfig()
      .then((apiConfig) {
        setState(() {
          Provider.of<HttpClientsModel>(context).setApiConfig(apiConfig);
        });

        Provider.of<UserDataModel>(context).readFromFile();
      });
  }

  Future<Map<String, dynamic>> getApiConfig() async {
    var jsonFile = await DefaultAssetBundle.of(context)
      .loadString('assets/api.json');

    Map<String, dynamic> apiConfig = jsonDecode(jsonFile);
    return apiConfig;
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
        home: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: <Widget>[
                  Tab(icon: Icon(Icons.wb_sunny),),
                  Tab(icon: Icon(Icons.list),),
                  Tab(icon: Icon(Icons.not_listed_location),),
                  Tab(icon: Icon(Icons.person_pin),),
                ],
              ),
              title: Text('Good Morning!'),
            ),
            body: TabBarView(
              children: <Widget>[
                QuotidianScreen(),
                RecentScreen(),
                RandomQuoteScreen(),
                AccountScreen(),
              ],
            ),
          ),
        )
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
