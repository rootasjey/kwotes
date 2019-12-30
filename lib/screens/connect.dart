import 'package:flutter/material.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/signup.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class Connect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: accent,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: <Widget>[
              Tab(text: 'SIGN IN'),
              Tab(text: 'SIGN UP',)
            ],
          ),
          title: Text(
            'Connect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back, color: Colors.white,),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Signin(),
            Signup(),
          ],
        ),
      ),
    );
  }
}
