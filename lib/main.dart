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
        home: HomePage(title: 'Memorare'),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _addQuote() {}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QuotidianWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuote,
        tooltip: 'Add quote',
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFF56498),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
