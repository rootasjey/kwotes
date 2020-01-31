import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorare/app_keys.dart';
import 'package:memorare/home_mobile.dart';
import 'package:memorare/home_web.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserDataModel>(create: (context) => UserDataModel(),),
        ChangeNotifierProvider<HttpClientsModel>(create: (context) => HttpClientsModel(uri: AppKeys.uri, apiKey: AppKeys.apiKey),),
        ChangeNotifierProvider<ThemeColor>(create: (context) => ThemeColor(),),
      ],
      child: DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
          fontFamily: 'Comfortaa',
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          if (kIsWeb) {
            return HomeWeb(theme: theme,);
          }

          return HomeMobile(theme: theme,);
        },
      ),
    );
  }
}
