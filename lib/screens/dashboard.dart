import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/simple_appbar.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/screens/account.dart';
import 'package:memorare/screens/add_quote/steps.dart';
import 'package:memorare/screens/recent_quotes.dart';
import 'package:memorare/screens/admin_temp_quotes.dart';
import 'package:memorare/screens/drafts.dart';
import 'package:memorare/screens/home/home.dart';
import 'package:memorare/screens/published_quotes.dart';
import 'package:memorare/screens/quotes_lists.dart';
import 'package:memorare/screens/quotidians.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/screens/signup.dart';
import 'package:memorare/screens/temp_quotes.dart';
import 'package:memorare/screens/web/favourites.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String avatarUrl = '';
  bool canManage = false;
  bool prevIsAuthenticated = false;
  bool isAccountAdvVisible = false;

  double beginY = 20.0;

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          appBar(),
          body(),
        ],
      ),
    );
  }

  Widget actionsButtons() {
    return SizedBox(
      height: 125.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: <Widget>[
          FadeInX(
            delay: 1.0,
            beginX: 50.0,
            child: signoutButton(),
          ),
          FadeInX(
            delay: 1.5,
            beginX: 50.0,
            child: newQuoteButton(),
          ),
          FadeInX(
            delay: 2.0,
            beginX: 50.0,
            child: quotidianButton(),
          ),
        ],
      ),
    );
  }

  List<Widget> adminWidgets(BuildContext context) {
    return [
      ControlledAnimation(
        duration: 1.seconds,
        tween: Tween(begin: 0.0, end: MediaQuery.of(context).size.width),
        builder: (_, value) {
          return SizedBox(
            width: value,
            child: Divider(height: 30.0),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.question_answer, size: 30.0),
        title: Text(
          'All published',
          style: TextStyle(fontSize: 20.0),
        ),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => RecentQuotes())),
      ),
      ListTile(
        leading: Icon(Icons.timelapse, size: 30.0),
        title: Text(
          'All in validation',
          style: TextStyle(fontSize: 20.0),
        ),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => AdminTempQuotes())),
      ),
      ListTile(
        leading: Icon(Icons.wb_sunny, size: 30.0),
        title: Text(
          'Quotidians',
          style: TextStyle(fontSize: 20.0),
        ),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => Quotidians())),
      ),
    ];
  }

  Widget appBar() {
    return SimpleAppBar(
      expandedHeight: 120.0,
      title: TextButton.icon(
        onPressed: () {
          scrollController.animateTo(
            0,
            duration: 250.milliseconds,
            curve: Curves.easeIn,
          );
        },
        icon: AppIconHeader(
          padding: EdgeInsets.zero,
          size: 30.0,
        ),
        label: Text(
          'Account',
          style: TextStyle(
            fontSize: 22.0,
          ),
        ),
      ),
      showNavBackIcon: false,
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
              child: settingsButton(),
            ),
          ],
        ),
      ),
    ];
  }

  Widget avatarContainer() {
    String userName = userState.username;
    String greetings = 'Welcome back $userName!';

    if (userName == null || userName.isEmpty) {
      greetings = 'Hi!';
    }

    if (prevIsAuthenticated != userState.isUserConnected) {
      prevIsAuthenticated = userState.isUserConnected;

      if (userState.isUserConnected) {
        fetchUserPP();
      } else {
        avatarUrl = '';
      }
    }

    return Column(
      children: [
        FadeInY(
          delay: 1,
          beginY: beginY,
          child: circlAvatar(),
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
      ],
    );
  }

  Widget body() {
    return Observer(builder: (context) {
      List<Widget> children = [];

      final isConnected = userState.isUserConnected;

      if (isConnected) {
        children.add(avatarContainer());
        children.addAll(authWidgets(context));

        if (canManage) {
          children.addAll(adminWidgets(context));
        }
      } else {
        children.add(whyAccountBlock());
        children.addAll(guestWidgets(context));
      }

      return SliverPadding(
        padding: const EdgeInsets.only(
          bottom: 200.0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            Column(
              crossAxisAlignment: isConnected
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: children,
            )
          ]),
        ),
      );
    });
  }

  Widget bulletPoint({String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
          ),
          Expanded(
            child: Opacity(
              opacity: 0.6,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget circlAvatar() {
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
            child: avatarUrl.isEmpty
                ? Image.asset('assets/images/user-${stateColors.iconExt}.png',
                    width: 100.0)
                : Image.asset(path, width: 100.0),
          ),
          onTap: () {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return AlertDialog(
                    content: avatarUrl.isEmpty
                        ? Image.asset(
                            'assets/images/user-${stateColors.iconExt}.png',
                            width: 100.0,
                            scale: .8,
                          )
                        : Image.asset(path, width: 100.0),
                  );
                });
          },
        ),
      ),
    );
  }

  Widget connectionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 60.0,
      ),
      child: Column(
        children: [
          signinButton(),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
          ),
          signupButton(),
        ],
      ),
    );
  }

  Widget draftsButton() {
    return ListTile(
      leading: Icon(
        Icons.edit,
        size: 30.0,
      ),
      title: Text(
        'Drafts',
        style: TextStyle(fontSize: 20.0),
      ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => Drafts())),
    );
  }

  Widget favButton() {
    return ListTile(
      leading: Icon(
        Icons.favorite,
        size: 30.0,
      ),
      title: Text(
        'Favourites',
        style: TextStyle(fontSize: 20.0),
      ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => Favourites())),
    );
  }

  List<Widget> guestWidgets(BuildContext context) {
    return [
      FadeInY(
        delay: 3.0,
        beginY: beginY,
        child: connectionButtons(),
      ),
      Divider(
        height: 100.0,
        thickness: 1.0,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInY(
              delay: 4.0,
              beginY: beginY,
              child: settingsButton(),
            ),
            FadeInY(
              delay: 4.5,
              beginY: beginY,
              child: helpCenterButton(),
            ),
          ],
        ),
      ),
    ];
  }

  Widget helpCenterButton() {
    return ListTile(
      leading: Icon(
        Icons.help_outline,
        size: 30.0,
      ),
      title: Text(
        'Help Center',
        style: TextStyle(fontSize: 20.0),
      ),
      onTap: () => launch('https://help.outofcontext.app'),
    );
  }

  Widget listsButton() {
    return ListTile(
      leading: Icon(
        Icons.list,
        size: 30.0,
      ),
      title: Text(
        'Lists',
        style: TextStyle(fontSize: 20.0),
      ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => QuotesLists())),
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
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => AddQuoteSteps()));
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
    return ListTile(
      leading: Icon(
        Icons.check,
        size: 30.0,
      ),
      title: Text(
        'Published',
        style: TextStyle(fontSize: 20.0),
      ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => MyPublishedQuotes())),
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
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Home()));
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

  Widget settingsButton() {
    return ListTile(
      leading: Icon(
        Icons.settings,
        size: 30.0,
      ),
      title: Text(
        'Settings',
        style: TextStyle(fontSize: 20.0),
      ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => Account())),
    );
  }

  Widget signinButton() {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
      },
      textColor: stateColors.primary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
          side: BorderSide(
            color: stateColors.primary,
          )),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 220.0,
          minHeight: 60.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'SIGN IN',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Icon(Icons.login),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget signupButton() {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signup()));
      },
      textColor: Colors.orange.shade600,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
          side: BorderSide(
            color: Colors.orange.shade600,
          )),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 220.0,
          minHeight: 60.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Icon(Icons.person_add),
              ),
            ],
          ),
        ),
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
                userState.signOut();

                setState(() {
                  canManage = false;
                });

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
    return ListTile(
      leading: Icon(
        Icons.timelapse,
        size: 30.0,
      ),
      title: Text(
        'In validation',
        style: TextStyle(fontSize: 20.0),
      ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => MyTempQuotes())),
    );
  }

  Widget whyAccountBlock() {
    return FadeInY(
      beginY: beginY,
      delay: 0.5,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 50.0,
          bottom: 30.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlatButton(
              onPressed: () =>
                  setState(() => isAccountAdvVisible = !isAccountAdvVisible),
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  'WHY AN ACCOUNT?',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (isAccountAdvVisible)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.only(top: 10.0)),
                  bulletPoint(text: 'Favourites quotes'),
                  bulletPoint(text: 'Create thematic lists'),
                  bulletPoint(text: 'Propose new quotes'),
                  bulletPoint(text: '& more...'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future fetchUserPP() async {
    final userAuth = await userState.userAuth;

    final user = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .get();

    final data = user.data;
    final String imageUrl = data['urls']['image'];

    canManage = data['rights']['user:managequote'] ?? false;

    if (avatarUrl == imageUrl) {
      return;
    }

    setState(() {
      avatarUrl = imageUrl;
    });
  }
}
