import 'package:flutter/material.dart';
import 'package:figstyle/components/quotidian_page.dart';

class Today extends StatefulWidget {
  @override
  _TodayState createState() => _TodayState();
}

class _TodayState extends State<Today> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          QuotidianPage(
            noAuth: true,
          ),
        ],
      ),
    );
  }
}
