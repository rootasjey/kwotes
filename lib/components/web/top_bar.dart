import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 60.0, top: 30.0),
          child: Image(
            image: AssetImage('assets/images/icon-small.png'),
            width: 50.0,
            height: 50.0,
          ),
        ),
      ],
    );
  }
}
