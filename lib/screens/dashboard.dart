import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/screens/account_settings.dart';
import 'package:memorare/screens/app_page_settings.dart';
import 'package:memorare/screens/published_quotes.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String avatarUrl = '';
  bool prevIsAuthenticated = false;

  double beginY = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 50.0,
        ),
        children: <Widget>[
          Observer(builder: (context) {
            String userName = appLocalStorage.getUserName();
            String greetings = 'Welcome back $userName!';

            if (userName == null || userName.isEmpty) {
              greetings = 'Hi Stranger!';
            }

            if (prevIsAuthenticated != userState.isUserConnected) {
              prevIsAuthenticated = userState.isUserConnected;

              if (userState.isUserConnected) { fetchUserPP(); }
              else { avatarUrl = ''; }
            }

            return Column(
              children: <Widget>[
                FadeInY(
                  delay: 1,
                  beginY: beginY,
                  child: avatar(),
                ),

                FadeInY(
                  delay: 2,
                  beginY: beginY,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      greetings,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                userState.isUserConnected ?
                  Column(children: authWidgets(context),) :
                  Column(children: guestWidgets(context)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget avatar() {
    String path = avatarUrl.replaceFirst('local:', '');
    path = 'assets/images/$path-${stateColors.iconExt}.png';

    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 60.0),
      child: Material(
        elevation: 4.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: avatarUrl.isEmpty ?
              Image.asset('assets/images/user-${stateColors.iconExt}.png', width: 100.0) :
              Image.asset(path, width: 100.0),
          ),
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return AlertDialog(
                  content: avatarUrl.isEmpty ?
                    Image.asset(
                      'assets/images/user-${stateColors.iconExt}.png',
                      width: 100.0,
                      scale: .8,
                    ) :
                    Image.asset(path, width: 100.0),
                );
              }
            );
          },
        ),
      ),
    );
  }

  Widget accountSettings() {
    return IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return AccountSettings();
            }
          )
        );
      },
    );
  }

  Widget appSettingsButton() {
    return FlatButton(
      child: ListTile(
        leading: Icon(Icons.settings, size: 30.0,),
        title: Text('App settings', style: TextStyle(fontSize: 20.0),),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return AppPageSettings();
            }
          )
        );
      },
    );
  }

  Widget actionsButtons() {
    return SizedBox(
      height: 125.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: <Widget>[
          signoutButton(),
          newQuoteButton(),
          quotidianButton(),
        ],
      ),
    );
  }

  List<Widget> authWidgets(BuildContext context) {
    return [
      actionsButtons(),

      Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            ControlledAnimation(
              duration: 1.seconds,
              tween: Tween(begin: 0.0, end: MediaQuery.of(context).size.width),
              builder: (_, value) {
                return SizedBox(
                  width: value,
                  child: Divider(),
                );
              },
            ),

            FadeInY(
              delay: 5.0,
              beginY: beginY,
              child: draftsButton(),
            ),

            FadeInY(
              delay: 6.0,
              beginY: beginY,
              child: listsButton(),
            ),

            FadeInY(
              delay: 7.0,
              beginY: beginY,
              child: tempQuotesButton(),
            ),

            FadeInY(
              delay: 8.0,
              beginY: beginY,
              child: favButton(),
            ),

            FadeInY(
              delay: 9.0,
              beginY: beginY,
              child: pubQuotesButton(),
            ),

            FadeInY(
              delay: 10.0,
              beginY: beginY,
              child: appSettingsButton(),
            ),
          ],
        ),
      ),
    ];
  }

  Widget draftsButton() {
    return FlatButton(
      child: ListTile(
        leading: Icon(Icons.edit, size: 30.0,),
        title: Text('Drafts', style: TextStyle(fontSize: 20.0),),
      ),
      onPressed: null,
    );
  }

  Widget favButton() {
    return FlatButton(
      child: ListTile(
        leading: Icon(Icons.favorite, size: 30.0,),
        title: Text('Favourites', style: TextStyle(fontSize: 20.0),),
      ),
      onPressed: () {
        FluroRouter.router.navigateTo(
          context,
          FavouritesRoute,
        );
      },
    );
  }

  List<Widget> guestWidgets(BuildContext context) {
    return [
      FadeInY(
        delay: 3.0,
        beginY: beginY,
        child: signinButton(),
      )
    ];
  }

  Widget listsButton() {
    return FlatButton(
      child: ListTile(
        leading: Icon(Icons.list, size: 30.0,),
        title: Text('Lists', style: TextStyle(fontSize: 20.0),),
      ),
      onPressed: () {
        FluroRouter.router.navigateTo(
          context,
          ListsRoute,
        );
      },
    );
  }

  Widget newQuoteButton() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 100.0,
      child: Column(
        children: <Widget>[
          Material(
            elevation: 4,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              onPressed: () {
                AddQuoteInputs.clearAll();
                AddQuoteInputs.navigatedFromPath = 'dashboard';
                FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
              },
              icon: Icon(
                Icons.add,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                'New quote',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget pubQuotesButton() {
    return FlatButton(
      child: ListTile(
        leading: Icon(Icons.check, size: 30.0,),
        title: Text('Published', style: TextStyle(fontSize: 20.0),),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return MyPublishedQuotes();
            }
          )
        );
      },
    );
  }

  Widget quotidianButton() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 100.0,
      child: Column(
        children: <Widget>[
          Material(
            elevation: 4,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              onPressed: () {
                FluroRouter.router.navigateTo(context, RootRoute);
              },
              icon: Icon(
                Icons.wb_sunny,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                'Quotidian',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget signinButton() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Observer(
        builder: (context) {
          return RaisedButton(
            onPressed: () {
              FluroRouter.router.navigateTo(context, SigninRoute);
            },
            color: stateColors.background.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: stateColors.primary),
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Sign In',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget signoutButton() {
    return Container(
      width: 100.0,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Material(
            elevation: 4,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              onPressed: () async {
                await appLocalStorage.clearUserAuthData();
                await FirebaseAuth.instance.signOut();
                userState.setUserDisconnected();

                showSnack(
                  context: context,
                  message: 'You have been successfully disconnected.',
                  type: SnackType.success,
                );
              },
              icon: Icon(
                Icons.exit_to_app,
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

  Widget tempQuotesButton() {
    return FlatButton(
      child: ListTile(
        leading: Icon(Icons.timelapse, size: 30.0,),
        title: Text('In validation', style: TextStyle(fontSize: 20.0),),
      ),
      onPressed: () {
        FluroRouter.router.navigateTo(context, TempQuotesRoute);
      },
    );
  }

  Future fetchUserPP() async {
    final userAuth = await FirebaseAuth.instance.currentUser();

    final user = await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .get();

    final data = user.data;
    final String imageUrl = data['urls']['image'];

    if (avatarUrl == imageUrl) { return; }

    setState(() {
      avatarUrl = imageUrl;
    });
  }
}
