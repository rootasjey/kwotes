import 'package:flutter/material.dart';
import 'package:memorare/components/web/discover.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_quotidian.dart';
import 'package:memorare/components/web/previous_quotidians.dart';
import 'package:memorare/components/web/top_bar.dart';
import 'package:memorare/components/web/topics.dart';

class HomeWeb extends StatefulWidget {
  final ThemeData theme;
  HomeWeb({Key key, this.theme}) : super(key: key);

  @override
  _HomeWebState createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorare',
      theme: widget.theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            TopBar(),
            FullPageQuotidian(),
            PreviousQuotidians(),
            Discover(),
            Topics(),
            Footer(),
          ],
        ),
      ),
    );
  }
}
