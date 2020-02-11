import 'package:flutter/material.dart';
import 'package:memorare/components/web/nav_back_header.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),

        Padding(
          padding: const EdgeInsets.only(bottom: 300.0),
          child: SizedBox(
            width: 300.0,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Sign in into your existing account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                FlatButton(
                  onPressed: () {},
                  child: Opacity(
                    opacity: .6,
                    child: Text(
                      "I don't have an account"
                    ),
                  )
                ),

                Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        autofocus: true,
                        decoration: InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          email = value;
                        },
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
                        padding: EdgeInsets.only(top: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              decoration: InputDecoration(
                                icon: Icon(Icons.lock_outline),
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              onChanged: (value) {
                                password = value;
                              },
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
                  padding: const EdgeInsets.only(top: 60.0),
                  child: FlatButton(
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Sign me in'),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Icon(Icons.arrow_forward),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
