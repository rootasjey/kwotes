import 'package:flutter/material.dart';
import 'package:memorare/screens/full_page_quotidian.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Out Of Context',
      theme: widget.theme,
      home: Scaffold(
        body: FullPageQuotidian(),
      ),
    );
  }
}
