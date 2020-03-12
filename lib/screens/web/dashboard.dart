import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/user_connection.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

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
                  FadeInX(
                    delay: .5,
                    beginX: 50.0,
                    child: signOutButton(),
                  ),

                  FadeInX(
                    delay: 1.0,
                    beginX: 50.0,
                    child: addQuoteButton(),
                  ),
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

  Widget accountSettingsCard() {
    return Padding(
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
            child: Container(
              padding: const EdgeInsets.all(60.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 40.0,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Account settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
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
                    AddQuoteInputs.clearAll();
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

        adminPubQuotesCard(),

        quotidiansCard(),

        adminTempQuotesCard(),
      ],
    );
  }

  Widget adminPubQuotesCard() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        width: 700.0,
        height: 200.0,
        child: Card(
          color: Color(0xFF00CF91),
          child: InkWell(
            onTap: () => FluroRouter.router.navigateTo(context, QuotesRoute),
            child: Container(
              padding: const EdgeInsets.all(60.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.cloud_done,
                    color: Colors.white,
                    size: 40.0,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Published quotes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget adminTempQuotesCard() {
    return Padding(
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
            child: Container(
              padding: const EdgeInsets.all(60.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.timelapse,
                    color: Colors.white,
                    size: 40.0,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Temporary quotes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  Widget cardsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: Column(
        children: <Widget>[
          FadeInY(
            delay: 2.0,
            beginY: 50.0,
            child: favouritesCard(),
          ),

          FadeInY(
            delay: 2.25,
            beginY: 50.0,
            child: tempQuotesCard(),
          ),

          FadeInY(
            delay: 2.5,
            beginY: 50.0,
            child: pubQuotesCard(),
          ),

          FadeInY(
            delay: 2.75,
            beginY: 50.0,
            child: accountSettingsCard(),
          ),
        ],
      ),
    );
  }

  Widget favouritesCard() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        width: 700.0,
        height: 200.0,
        child: Card(
          color: Color(0xFFFF005C),
          child: InkWell(
            onTap: () => FluroRouter.router.navigateTo(context, FavouritesRoute),
            child: Container(
              padding: const EdgeInsets.all(60.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40.0,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Favourites',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget greetings() {
    if (userAuth == null) {
      return Padding(padding: EdgeInsets.zero,);
    }

    final name = userAuth.displayName != null ?
      userAuth.displayName : userAuth.email;

    return ControlledAnimation(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: 1.seconds,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Hello $name!',
          style: TextStyle(
            fontSize: 30.0,
          ),
        ),
      ),
      builderWithChild: (context, child, value) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
    );
  }

  Widget pubQuotesCard() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        width: 700.0,
        height: 200.0,
        child: Card(
          color: Color(0xFF00CF91),
          child: InkWell(
            onTap: () => FluroRouter.router.navigateTo(context, PublishedQuotesRoute),
            child: Container(
              padding: const EdgeInsets.all(60.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.cloud_done,
                    color: Colors.white,
                    size: 40.0,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Published quotes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget quotidiansCard() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        width: 700.0,
        height: 200.0,
        child: Card(
          color: Color(0xFFFFAF50),
          child: InkWell(
            onTap: () => FluroRouter.router.navigateTo(context, QuotidiansRoute),
            child: Container(
              padding: const EdgeInsets.all(60.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.today,
                    color: Colors.white,
                    size: 40.0,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Quotidians',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
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
                    setUserDisconnected();

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

  Widget tempQuotesCard() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        width: 700.0,
        height: 200.0,
        child: Card(
          color: Color(0xFF2E3F7F),
          child: InkWell(
            onTap: () {
              FluroRouter.router.navigateTo(context, TempQuotesRoute);
            },
            child: Container(
              padding: const EdgeInsets.all(60.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.timelapse,
                    color: Colors.white,
                    size: 40.0,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Temporary quotes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
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
