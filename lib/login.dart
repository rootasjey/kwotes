import 'package:flutter/material.dart';

import 'signin.dart';
import 'signup.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: <Widget>[
              Tab(text: 'SIGN IN'),
              Tab(text: 'SIGN UP',)
            ],
          ),
          title: Text('Login'),
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
