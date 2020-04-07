import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorare/app_keys.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/main_mobile.dart';
import 'package:memorare/main_web.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:provider/provider.dart';

void main() {
  return runApp(App());
}

class App extends StatefulWidget {
  AppState createState() => AppState();
}

class AppState extends State<App> {
  bool isReady = false;

  AppState() {
    if (kIsWeb) { FluroRouter.setupWebRouter(); }
    else { FluroRouter.setupMobileRouter(); }
  }

  @override
  void initState() {
    super.initState();

    appLocalStorage.initialize()
      .then((value) {
        setState(() {
          isReady = true;
        });
      });

    appTopicsColors.fetchTopicsColors();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserDataModel>(create: (context) => UserDataModel(),),
        ChangeNotifierProvider<HttpClientsModel>(create: (context) => HttpClientsModel(uri: AppKeys.uri, apiKey: AppKeys.apiKey),),
        ChangeNotifierProvider<ThemeColor>(create: (context) => ThemeColor(),),
      ],
      child: isReady ?
        DynamicTheme(
          defaultBrightness: Brightness.light,
          data: (brightness) => ThemeData(
            fontFamily: 'Comfortaa',
            brightness: brightness,
          ),
          themedWidgetBuilder: (context, theme) {
            stateColors.themeData = theme;

            if (kIsWeb) {
              return MainWeb(theme: theme,);
            }

            return MainMobile(theme: theme,);
          },
        ) :
        MaterialApp(
          title: 'Out Of Context',
          home: Scaffold(
            body: FullPageLoading(),
          ),
        ),
    );
  }
}
