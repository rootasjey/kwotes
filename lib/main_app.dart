import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/utils/snack.dart';

/// Executed from main.dart
class MainApp extends StatefulWidget {
  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  @override
  void initState() {
    NavigationHelper.navigatorKey = GlobalKey<NavigatorState>();

    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fig.style',
      theme: stateColors.themeData,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationHelper.navigatorKey,
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
}
