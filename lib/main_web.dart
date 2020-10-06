import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:supercharged/supercharged.dart';

import 'screens/web/home.dart';

class MainWeb extends StatefulWidget {
  @override
  _MainWebState createState() => _MainWebState();
}

class _MainWebState extends State<MainWeb> {
  @override
  initState() {
    super.initState();
    loadBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Out Of Context',
      theme: stateColors.themeData,
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }

  void loadBrightness() {
    final autoBrightness = appLocalStorage.getAutoBrightness();

    if (!autoBrightness) {
      final currentBrightness = appLocalStorage.getBrightness();
      stateColors.refreshTheme(currentBrightness);

      return;
    }

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
