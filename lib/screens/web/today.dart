import 'package:flutter/material.dart';
import 'package:memorare/components/web/full_page_quotidian.dart';

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
          FullPageQuotidian(noAuth: true,),
        ],
      ),
    );
  }
}
