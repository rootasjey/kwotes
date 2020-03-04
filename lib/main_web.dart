import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/state/user_connection.dart';
import 'package:memorare/utils/language.dart';
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

    populateAuthAndLang();
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

  void populateAuthAndLang() async {
    final userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth != null) {
      setUserConnected();
    }

    Language.fetchAndPopulate(userAuth);
  }

}
