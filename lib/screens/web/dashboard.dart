import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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

          greetings(),

          signOutButton(),

          cardsList(),
        ],
      ),
    );
  }

  Widget cardsList() {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              width: 700.0,
              height: 200.0,
              child: Card(
                color: Color(0xFF414042),
                child: InkWell(
                  onTap: () {
                    FluroRouter.router.navigateTo(context, AccountRoute);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: Text(
                      'Account settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget greetings() {
    if (userAuth == null) {
      return Padding(padding: EdgeInsets.zero,);
    }

    final name = userAuth.displayName != null ?
      userAuth.displayName : userAuth.email;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        'Hello $name!',
        style: TextStyle(
          color: Colors.black,
          fontSize: 30.0,
        ),
      ),
    );
  }

  Widget signOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Wrap(
        children: <Widget>[
          Column(
            children: <Widget>[
              Material(
                color: Color(0xFF58595B),
                elevation: 1,
                shape: CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    FluroRouter.router.navigateTo(context, HomeRoute);
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Opacity(
                  opacity: .7,
                  child: Text(
                    'Sign out',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
