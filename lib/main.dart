import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/main_mobile.dart';
import 'package:memorare/main_web.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/push_notifications.dart';

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
        final savedLang = appLocalStorage.getLang();
        userState.setLang(savedLang);

        autoLogin();

        setState(() {
          isReady = true;
        });
      });

    appTopicsColors.fetchTopicsColors();
  }

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
          fontFamily: 'Comfortaa',
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          stateColors.themeData = theme;

          if (kIsWeb) {
            return MainWeb();
          }

          return MainMobile();
        },
      );
    }

    return MaterialApp(
      title: 'Out Of Context',
      home: Scaffold(
        body: FullPageLoading(),
      ),
    );
  }

  void autoLogin() async {
    try {
      final credentials = appLocalStorage.getCredentials();

      if (credentials == null) { return; }

      final email = credentials['email'];
      final password = credentials['password'];

      if ((email == null || email.isEmpty) || (password == null || password.isEmpty)) {
        return;
      }

      final authResult = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

      if (authResult.user == null) {
        throw Error();
      }

      appLocalStorage.saveUserName(authResult.user.displayName);
      userState.setUserConnected();

      if (Platform.isAndroid || Platform.isIOS) {
        PushNotifications.initialize(userUid: authResult.user.uid);
      }

    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
