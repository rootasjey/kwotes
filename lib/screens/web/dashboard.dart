import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FirebaseUser userAuth;
  bool canManage = false;

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 300.0),
      child: Column(
        children: <Widget>[
          NavBackHeader(),

          greetings(),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: SizedBox(
              height: 150.0,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  signOutButton(),
                  addQuoteButton(),
                ],
              ),
            ),
          ),

          cardsList(),

          if (canManage)
            adminCardLists(),
        ],
      ),
    );
  }

  Widget cardsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
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
          ),
        ],
      ),
    );
  }

  Widget adminCardLists() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100.0,
              child: Divider(
                thickness: 1.0,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('ADMIN'),
            ),

            SizedBox(
              width: 100.0,
              child: Divider(
                thickness: 1.0,
              ),
            ),
          ],
        ),

        Padding(padding: const EdgeInsets.only(top: 20.0),),

        Padding(
          padding: const EdgeInsets.all(30.0),
          child: SizedBox(
            width: 700.0,
            height: 200.0,
            child: Card(
              color: Color(0xFF00CF91),
              child: InkWell(
                onTap: () {
                  FluroRouter.router.navigateTo(context, QuotesRoute);
                },
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Text(
                    'Published quotes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              )
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(30.0),
          child: SizedBox(
            width: 700.0,
            height: 200.0,
            child: Card(
              color: Color(0xFFFFAF50),
              child: InkWell(
                onTap: () {
                  FluroRouter.router.navigateTo(context, QuotidiansRoute);
                },
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Text(
                    'Quotidians',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              )
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(30.0),
          child: SizedBox(
            width: 700.0,
            height: 200.0,
            child: Card(
              color: Color(0xFF2E3F7F),
              child: InkWell(
                onTap: () {
                  FluroRouter.router.navigateTo(context, AdminTempQuotesRoute);
                },
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Text(
                    'Temporary quotes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              )
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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

  Widget addQuoteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  onPressed: () {
                    FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Opacity(
                  opacity: .7,
                  child: Text(
                    'Add a qutoe',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void checkAuthStatus() async {
    userAuth = await FirebaseAuth.instance.currentUser();

    setState(() {});

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }

    final user = await FirestoreApp.instance
      .collection('users')
      .doc(userAuth.uid)
      .get();

    if (!user.exists) { return; }

    setState(() {
      canManage = user.data()['rights']['user:managequote'] == true;
    });
  }
}
