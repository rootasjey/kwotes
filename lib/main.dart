import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/quotidian.dart';

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
          primarySwatch: Colors.green,
        ),
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF706FF0),
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(icon: Icon(Icons.wb_sunny),),
                  Tab(icon: Icon(Icons.list),),
                  Tab(icon: Icon(Icons.person_pin),),
                ],
              ),
              title: Text('Memorare'),
            ),
            body: TabBarView(
              children: <Widget>[
                QuotidianWidget(),
                Icon(Icons.list),
                Icon(Icons.person),
              ],
            ),
          ),
        )
      ),
    );
  }
}
