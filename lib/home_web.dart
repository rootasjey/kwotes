import 'package:flutter/material.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/utils/router.dart';

class HomeWeb extends StatefulWidget {
  final ThemeData theme;
  HomeWeb({Key key, this.theme}) : super(key: key);

  @override
  _HomeWebState createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  @override
  initState() {
    super.initState();
    ThemeColor.fetchTopicsColors();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorare',
      theme: widget.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: FluroRouter.router.generator,
    );
  }
}
