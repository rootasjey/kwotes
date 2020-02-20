import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  String email = '';
  String password = '';
  bool isCompleted = false;
  bool isLoading = false;

  final _passwordNode = FocusNode();

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordNode.dispose();
  }

  void checkAuthStatus() async {
    final user = await FirebaseAuth.instance.currentUser();

    if (user != null) {
      FluroRouter.router.navigateTo(context, DashboardRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),

        Padding(
        padding: const EdgeInsets.only(bottom: 300.0),
        child: SizedBox(
          width: 300.0,
          child: content(),
        ),
      ),
      ],
    );
  }

  Widget content() {
    if (isCompleted) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Icon(
              Icons.check_circle,
              size: 80.0,
              color: Colors.green,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
            child: Text(
              'You are now logged in!',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 15.0,),
            child: FlatButton(
              onPressed: () {
                FluroRouter.router.navigateTo(
                  context,
                  DashboardRoute,
                );
              },
              child: Opacity(
                opacity: .6,
                child: Text(
                  'Go to your dashboard',
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (isLoading) {
      return Column(
        children: <Widget>[
          CircularProgressIndicator(),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text(
              'Signing in...',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          )
        ],
      );
    }

    return Column(
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
          onPressed: () {
            FluroRouter.router.navigateTo(
              context,
              SignupRoute,
            );
          },
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
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_passwordNode);
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
                focusNode: _passwordNode,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock_outline),
                  labelText: 'Password',
                ),
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                onFieldSubmitted: (value) {
                  if (value.length == 0) { return; }
                  connectAccount();
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
            onPressed: () {
              connectAccount();
            },
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
    );
  }

  void connectAccount() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

      if (result.user == null) {
        showSnack(message: 'The password is incorrect or the user does not exists.');
        return;
      }

      AppLocalStorage.saveEmail(email);

      setState(() {
        isLoading = false;
        isCompleted = true;
      });

      await Language.fetchLang(result.user);

    } catch (error) {
      showSnack(
        message: 'The password is incorrect or the user does not exists.',
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  void showSnack({String message}) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      )
    );
  }
}
