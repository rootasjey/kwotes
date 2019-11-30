import 'package:flutter/material.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/signup.dart';

class LoginScreen extends StatelessWidget {
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
            SigninScreen(),
            SignupScreen(),
          ],
        ),
      ),
    );
  }
}
