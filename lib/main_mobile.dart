import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class MainMobile extends StatefulWidget {
  @override
  MainMobileState createState() => MainMobileState();
}

class MainMobileState extends State<MainMobile> {
  @override
  void initState() {
    super.initState();
    checkConnection();
    loadBrightness();
    autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Out Of Context',
      theme: stateColors.themeData,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: FluroRouter.router.generator,
    );
  }

  // TODO: Move to main?
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

    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void checkConnection() async {
    final hasConnection = await DataConnectionChecker().hasConnection;

    if (!hasConnection) {
      showSnack(
        context: context,
        message: "It seems that you're offline",
        type: SnackType.error,
      );
    }
  }

  void loadBrightness() {
    final now = DateTime.now();

    Brightness brightness = Brightness.light;

    if (now.hour < 6 || now.hour > 17) {
      brightness = Brightness.dark;
    }

    Future.delayed(
      2.seconds,
      () {
        try {
          DynamicTheme.of(context).setBrightness(brightness);
          stateColors.refreshTheme(brightness);

        } catch (error) {
          debugPrint(error.toString());
        }
      }
    );
  }
}
