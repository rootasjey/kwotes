import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:figstyle/types/enums.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

/// Executed from main.dart
class MainApp extends StatefulWidget {
  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // checkConnection();
    loadBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fig.style',
      theme: stateColors.themeData,
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
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

    Future.delayed(2.seconds, () {
      try {
        DynamicTheme.of(context).setBrightness(brightness);
        stateColors.refreshTheme(brightness);
      } catch (error) {
        debugPrint(error.toString());
      }
    });
  }
}
