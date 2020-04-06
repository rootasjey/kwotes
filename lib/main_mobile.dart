import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:supercharged/supercharged.dart';

class MainMobile extends StatefulWidget {
  final ThemeData theme;

  MainMobile({this.theme});

  @override
  MainMobileState createState() => MainMobileState();
}

class MainMobileState extends State<MainMobile> {
  @override
  void initState() {
    super.initState();
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
