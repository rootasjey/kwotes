import 'package:flutter/material.dart';
import 'package:memorare/components/web/discover.dart';
import 'package:memorare/components/web/full_page_quotidian.dart';
import 'package:memorare/components/web/previous_quotidians.dart';
import 'package:memorare/components/web/top_bar.dart';
import 'package:memorare/components/web/topics.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
          TopBar(),
          FullPageQuotidian(),
          PreviousQuotidians(),
          Discover(),
          Topics(),
      ],
    );
  }
}
