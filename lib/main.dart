import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/quotidian.dart';
import 'package:memorare/recent.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  AppState createState() => AppState();
}

class AppState extends State<App> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _children = [
    QuotidianWidget(),
    RecentWidget(),
    Icon(Icons.person),
  ];

  TabController _tabController;

  bool isAuth = false;
  ValueNotifier<GraphQLClient> client;

  void _tabChanged () {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(vsync: this, length: _children.length);
    _tabController.addListener(_tabChanged);

    createClient()
      .then((newClient) {
        setState(() {
          client = newClient;
        });
      });
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabChanged);
    _tabController.dispose();
    super.dispose();
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
          primarySwatch: MaterialColor(0xFFF56498, accentSwatchColor),
        ),
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Color(0xFF706FF0),
              selectedFontSize: 16.0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Color(0xFFFFFFEE),
              currentIndex: _currentIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.wb_sunny),
                  title: Text('Today'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  title: Text('Recent'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_pin),
                  title: Text('Account'),
                ),
              ],
              onTap: (int index) {
                _tabController.animateTo(index);
              },
            ),
            body: TabBarView(
              children: _children,
              controller: _tabController,
            ),
          ),
        )
      ),
    );
  }
}

Map<int, Color> accentSwatchColor = {
  50: Color.fromRGBO(245, 100, 152, .1),
  100: Color.fromRGBO(245, 100, 152, .2),
  200: Color.fromRGBO(245, 100, 152, .3),
  300: Color.fromRGBO(245, 100, 152, .4),
  400: Color.fromRGBO(245, 100, 152, .5),
  500: Color.fromRGBO(245, 100, 152, .6),
  600: Color.fromRGBO(245, 100, 152, .7),
  700: Color.fromRGBO(245, 100, 152, .8),
  800: Color.fromRGBO(245, 100, 152, .9),
  900: Color.fromRGBO(245, 100, 152, 1),
};
