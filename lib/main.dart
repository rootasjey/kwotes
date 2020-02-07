import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase/firebase.dart' as Firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorare/app_keys.dart';
import 'package:memorare/common/firebase_config.dart';
import 'package:memorare/home_mobile.dart';
import 'package:memorare/home_web.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/utils/router.dart';
import 'package:provider/provider.dart';

void main() {
  if (Firebase.apps.isEmpty) {
    Firebase.initializeApp(
      apiKey: FirebaseConfig.apiKey,
      authDomain: FirebaseConfig.authDomain,
      databaseURL: FirebaseConfig.databaseURL,
      projectId: FirebaseConfig.projectId,
      storageBucket: FirebaseConfig.storageBucket,
      messagingSenderId: FirebaseConfig.messagingSenderId,
      appId: FirebaseConfig.appId,
      measurementId: FirebaseConfig.measurementId,
    );
  }

  FluroRouter.setupRouter();

  return runApp(App());
}

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
