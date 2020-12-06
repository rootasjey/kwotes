import 'package:figstyle/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/state/colors.dart';

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
}
