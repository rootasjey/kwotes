import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_connection.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/router.dart';
import 'package:supercharged/supercharged.dart';

class MainWeb extends StatefulWidget {
  final ThemeData theme;
  MainWeb({Key key, this.theme}) : super(key: key);

  @override
  _MainWebState createState() => _MainWebState();
}

class _MainWebState extends State<MainWeb> {
  @override
  initState() {
    super.initState();
    populateAuthAndLang();
    loadBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Out Of Context',
      theme: widget.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: FluroRouter.router.generator,
    );
  }

  void loadBrightness() {
    final autoBrightness = AppLocalStorage.getAutoBrightness();

    if (!autoBrightness) {
      final currentBrightness = AppLocalStorage.getBrightness();
      stateColors.refreshTheme(currentBrightness);

      return;
    }

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

  void populateAuthAndLang() async {
    final userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth != null) {
      setUserConnected();
    }

    Language.fetchAndPopulate(userAuth);
  }
}
