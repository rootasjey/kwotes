import 'package:flutter/material.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/utils/router.dart';

class MainWeb extends StatefulWidget {
  final ThemeData theme;
  MainWeb({Key key, this.theme}) : super(key: key);

  @override
  _MainWebState createState() => _MainWebState();
}

class _MainWebState extends State<MainWeb> {
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
