import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  @override
  SignupSate createState() => SignupSate();
}

class SignupSate extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text('Email'),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Email login cannot be empty';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text('Password'),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password login cannot be empty';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: RaisedButton(
              onPressed: () { print('signup'); },
              child: Text('Sign in'),
            ),
          )
        ],
      ),
    );
  }
}