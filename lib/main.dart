import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/account.dart';
import 'package:memorare/quotidian.dart';
import 'package:memorare/randomQuote.dart';
import 'package:memorare/recent.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  AppState createState() => AppState();
}

class AppState extends State<App> {
  bool isAuth = false;
  ValueNotifier<GraphQLClient> client;

  @override
  void initState() {
    super.initState();

    createClient()
      .then((newClient) {
        setState(() {
          client = newClient;
        });
      });
  }

  Future<Map<String, dynamic>> getApiConfig() async {
    var jsonFile = await DefaultAssetBundle.of(context)
      .loadString('assets/api.json');

    Map<String, dynamic> apiConfig = jsonDecode(jsonFile);
    return apiConfig;
  }

  Future<ValueNotifier<GraphQLClient>> createClient() async {
    var apiConfig = await getApiConfig();

    final HttpLink httpLink = HttpLink(
      uri: apiConfig['url'],
      headers: {
        'apikey': apiConfig['apikey'],
      }
    );

    ValueNotifier<GraphQLClient> graphQLClient = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink,
        ),
    );

    return graphQLClient;
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
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
                QuotidianWidget(),
                RecentWidget(),
                RandomQuoteWidget(),
                AccountWidget(),
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
