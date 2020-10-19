import 'package:flutter/material.dart';
import 'package:memorare/components/app_icon.dart';

class TopBar extends StatefulWidget {
  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AppIcon(
          padding: const EdgeInsets.only(left: 60.0, top: 30.0),
          size: 50.0,
        ),
      ],
    );
  }
}
