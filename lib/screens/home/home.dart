import 'package:flutter/material.dart';
import 'package:memorare/screens/home/home_desktop.dart';
import 'package:memorare/screens/home/home_mobile.dart';

class Home extends StatefulWidget {
  Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600.0) {
          return HomeMobile();
        }

        return HomeDesktop();
      },
    );
  }
}
