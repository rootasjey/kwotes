import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isLoading = false;
  bool isCompleted = false;
  FirebaseUser userAuth;

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  void checkAuthStatus() async {
    userAuth = await FirebaseAuth.instance.currentUser();

    setState(() {});

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 300.0),
      child: Column(
        children: <Widget>[
          NavBackHeader(),

          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 120.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                'You can update your account settings here.',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            )
          ),

          RaisedButton(
            onPressed: () {
              FluroRouter.router.navigateTo(context, DeleteAccountRoute);
            },
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Delete account',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
