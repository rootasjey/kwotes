import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/users.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/screens/settings.dart';
import 'package:memorare/screens/recent_quotes.dart';
import 'package:memorare/screens/admin_temp_quotes.dart';
import 'package:memorare/screens/drafts.dart';
import 'package:memorare/screens/published_quotes.dart';
import 'package:memorare/screens/quotes_lists.dart';
import 'package:memorare/screens/quotidians.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/temp_quotes.dart';
import 'package:memorare/screens/favourites.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

import '../add_quote/steps.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool canManage = false;
  bool isCheckingAuth = false;

  @override
  void initState() {
    super.initState();
    chechAndGetUser();
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingAuth) {
      return FullPageLoading();
    }

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
          if (canManage) adminCardLists(),
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
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Settings()));
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
            )),
      ),
    );
  }

  Widget addQuoteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          Material(
            color: Color(0xFF58595B),
            elevation: 1,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              onPressed: () {
                AddQuoteInputs.clearAll();
                AddQuoteInputs.navigatedFromPath = 'dashboard';
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => AddQuoteSteps()));
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
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
        ),
        Wrap(
          spacing: 20.0,
          runSpacing: 20.0,
          children: <Widget>[
            FadeInY(
              delay: 2.0,
              beginY: 50.0,
              child: itemCard(
                color: Color(0xFF00CF91),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => RecentQuotes())),
                icon: Icon(
                  Icons.cloud_done,
                  color: Colors.white,
                  size: 40.0,
                ),
                text: Text(
                  'All published quotes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            FadeInY(
              delay: 2.0,
              beginY: 50.0,
              child: itemCard(
                color: Color(0xFFFFAF50),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Quotidians())),
                icon: Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 40.0,
                ),
                text: Text(
                  'Quotidians',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            FadeInY(
              delay: 2.0,
              beginY: 50.0,
              child: itemCard(
                color: Color(0xFF2E3F7F),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => AdminTempQuotes())),
                icon: Icon(
                  Icons.timelapse,
                  color: Colors.white,
                  size: 40.0,
                ),
                text: Text(
                  'All in validation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget cardsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60.0,
        horizontal: 40.0,
      ),
      child: Wrap(
        spacing: 30.0,
        runSpacing: 30.0,
        children: <Widget>[
          FadeInY(
            delay: 2.0,
            beginY: 50.0,
            child: itemCard(
              color: Color(0xFFFF005C),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Favourites())),
              icon: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 40.0,
              ),
              text: Text(
                'Favourites',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          FadeInY(
            delay: 2.10,
            beginY: 50.0,
            child: itemCard(
              color: Color(0xFF0260E8),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => QuotesLists())),
              icon: Icon(
                Icons.list,
                color: Colors.white,
                size: 40.0,
              ),
              text: Text(
                'Lists',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          FadeInY(
            delay: 2.25,
            beginY: 50.0,
            child: itemCard(
              color: Color(0xFF2E3F7F),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => MyTempQuotes())),
              icon: Icon(
                Icons.timelapse,
                color: Colors.white,
                size: 40.0,
              ),
              text: Text(
                'In validation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          FadeInY(
            delay: 2.5,
            beginY: 50.0,
            child: itemCard(
              color: Color(0xFF00CF91),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => MyPublishedQuotes())),
              icon: Icon(
                Icons.cloud_done,
                color: Colors.white,
                size: 40.0,
              ),
              text: Text(
                'Published quotes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          FadeInY(
            delay: 2.75,
            beginY: 50.0,
            child: itemCard(
              color: Color(0xFF414042),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Drafts())),
              icon: Icon(
                Icons.edit,
                color: Colors.white,
                size: 40.0,
              ),
              text: Text(
                'Drafts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          FadeInY(
            delay: 2.95,
            beginY: 50.0,
            child: itemCard(
              color: Color(0xFF414042),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Settings())),
              icon: Icon(
                Icons.settings,
                color: Colors.white,
                size: 40.0,
              ),
              text: Text(
                'Account settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemCard({
    Icon icon,
    Text text,
    Function onTap,
    Color color,
  }) {
    return SizedBox(
      width: 200.0,
      height: 250.0,
      child: Card(
        color: color,
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                icon,
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: text,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget greetings() {
    final displayName = appLocalStorage.getUserName();
    final credentials = appLocalStorage.getCredentials();

    String email = '';

    if (credentials != null && credentials['email'] != null) {
      email = credentials['email'];
    }

    if (!userState.isUserConnected) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final name = displayName != null ? displayName : email;

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

  Widget signOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          Material(
            color: Color(0xFF58595B),
            elevation: 1,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              onPressed: () {
                userSignOut(context: context);
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
    );
  }

  void chechAndGetUser() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isCheckingAuth = false;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final user = await Firestore.instance
          .collection('users')
          .document(userAuth.uid)
          .get();

      if (!user.exists) {
        return;
      }

      setState(() {
        isCheckingAuth = false;
        canManage = user.data['rights']['user:managequote'] == true;
      });
    } catch (error) {
      isCheckingAuth = false;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
    }
  }
}
