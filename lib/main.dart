import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/app_notifications.dart';
import 'package:memorare/background_tasks.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/account.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/screens/discover.dart';
import 'package:memorare/screens/quotidians.dart';
import 'package:memorare/screens/topics.dart';
import 'package:memorare/types/app_settings.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    bool isExecutionAllowed = true;

    switch (task) {
      case BackgroundTasks.name:
        debugPrint('android background task');
        break;
      case Workmanager.iOSBackgroundTask:
        debugPrint('iOS background fetch');
        await AppSettings.readFromFile();
        isExecutionAllowed = AppSettings.isQuotidianNotifActive;
        break;
    }

    if (!isExecutionAllowed) {
      debugPrint('Execution stopped because settings prevent it (probably on iOS).');
      return Future.value(true);
    }

    final quotidian = await BackgroundTasks.fetchQuotidian();
    if (quotidian == null) { return Future.value(true); }

    AppNotifications.initialize();
    await AppNotifications.scheduleNotifications(quotidian: quotidian);
    return Future.value(true);
  });
}

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
          Provider.of<HttpClientsModel>(context, listen: false).setApiConfig(apiConfig);
        });

        final userDataModel = Provider.of<UserDataModel>(context, listen: false);

        userDataModel.readFromFile()
          .then((_) {
            Provider.of<HttpClientsModel>(context, listen: false)
              .setToken(
                token: userDataModel.data.token,
                context: context
              );
          })
          .then((_) {
            Queries.todayTopic(context)
              .then((topic) {
                Provider.of<ThemeColor>(context, listen: false).updatePalette(context, topic);
              });
          })
          .then((_) {
            if (userDataModel.data.id == null || userDataModel.data.id.isEmpty) {
              return;
            }

            userDataModel.fetchAndUpdate(context);
          })
          .then((_) {
            Workmanager.initialize(callbackDispatcher, isInDebugMode: true);
            AppNotifications.initialize(context: context);

            AppSettings.readFromFile()
              .then((_) {
                if (AppSettings.isFirstLaunch) {
                  AppSettings.updateFirstLaunch(false);
                  AppNotifications.scheduleNotifications();

                  if (Platform.isAndroid) {
                    Workmanager.registerPeriodicTask(
                      '1',
                      BackgroundTasks.name,
                      frequency: Duration(hours: 6),
                      constraints: Constraints(
                        networkType: NetworkType.connected,
                      ),
                    );
                  }
                }
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
