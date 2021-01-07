import 'dart:async';

import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/push_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OnBoarding extends StatefulWidget {
  final bool isDesktop;

  OnBoarding({
    this.isDesktop = false,
  });

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  bool notificationsON = false;
  bool isAuth = false;

  final double bodyOpacity = 0.6;
  final double fontSizeDesc = 18.0;
  double horizontalPadding = 20.0;
  final double illusSize = 300.0;

  Timer timer;

  @override
  void initState() {
    super.initState();
    initProps();
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null && timer.isActive) {
      timer.cancel();
      toggleQuotidianNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    horizontalPadding = MediaQuery.of(context).size.width < 700.0 ? 20.0 : 60.0;

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome!",
          bodyWidget: Container(
            width: 400.0,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Opacity(
              opacity: bodyOpacity,
              child: Text(
                "fig.style is your daily quote app. Let's see what you can do with it.",
                style: TextStyle(
                  fontSize: fontSizeDesc,
                ),
              ),
            ),
          ),
          image: Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Center(
              child: Image.asset(
                "assets/images/app-icon-512-alt.png",
                height: 500.0,
                width: 500.0,
              ),
            ),
          ),
        ),
        PageViewModel(
          title: "Discover & Share",
          bodyWidget: Container(
            width: 400.0,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Opacity(
              opacity: bodyOpacity,
              child: Text(
                "You can discover new quotes by authors and references, "
                "or search for keywords. When you've found the perfect quote, "
                "you can share it with others, like it or add it to a list. "
                "And there's more.",
                style: TextStyle(
                  fontSize: fontSizeDesc,
                ),
              ),
            ),
          ),
          image: Center(
            child: Image.asset(
              'assets/images/illus_features.png',
              semanticLabel: 'Features illustration',
              width: illusSize,
              height: illusSize,
            ),
          ),
        ),
        notificationsPVModel(),
        PageViewModel(
          title: "Community",
          bodyWidget: Container(
            width: 400.0,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Opacity(
                opacity: bodyOpacity,
                child: Text(
                  "You can contribute by adding new quotes to the database, "
                  "giving your feedback, or fixing wrong information.",
                  style: TextStyle(
                    fontSize: fontSizeDesc,
                  ),
                )),
          ),
          image: Center(
            child: Image.asset(
              'assets/images/illus_community.png',
              semanticLabel: 'Community illustration',
              width: illusSize,
              height: illusSize,
            ),
          ),
        ),
        accountPVModel(),
      ],
      onDone: () {
        appStorage.setFirstLaunch();
        stateUser.setFirstLaunch(false);

        if (widget.isDesktop) {
          return Navigator.of(context).pop();
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return Home();
            },
          ),
        );
      },
      showSkipButton: true,
      next: const Text("Next"),
      skip: const Text("Skip"),
      done: const Text("Done"),
    );
  }

  void initProps() async {
    if (!kIsWeb) {
      notificationsON = await PushNotifications.isActive();
    }

    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      isAuth = user != null;
    });
  }

  void toggleQuotidianNotifications() async {
    if (notificationsON) {
      PushNotifications.activate();
      return;
    }

    PushNotifications.deactivate();
  }

  PageViewModel notificationsPVModel() {
    double paddingTop = 100.0;

    String body = "You don't have to open the app to be inspired. "
        "One quote will be delivered to you everyday around 8:00 am.";

    Widget footer = SwitchListTile(
      onChanged: (bool value) {
        setState(() {
          notificationsON = value;
        });

        timer?.cancel();
        timer =
            Timer(Duration(seconds: 1), () => toggleQuotidianNotifications());
      },
      value: notificationsON,
      title: Text(
        'Daily quote',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle:
          Text("If this is active, you will receive a daily notification"),
      secondary: notificationsON
          ? Icon(Icons.notifications_active)
          : Icon(Icons.notifications_off),
    );

    if (kIsWeb) {
      paddingTop = 0.0;
      body = "You don't have to open your mobile app to be inspired. "
          "Get the Android or iOS app now, "
          "and one quote will be delivered to you everyday around 8:00 am.";

      footer = Wrap(
        spacing: 20.0,
        children: [
          storeCard(
            icon: FaIcon(
              FontAwesomeIcons.googlePlay,
              size: 40.0,
              color: Colors.green,
            ),
            url:
                "https://play.google.com/store/apps/details?id=com.outofcontext.app",
          ),
          storeCard(
            icon: FaIcon(
              FontAwesomeIcons.appStoreIos,
              size: 40.0,
              color: Colors.blue,
            ),
            url:
                "https://apps.apple.com/us/app/out-of-context/id1516117110?ls=1",
          ),
        ],
      );
    }

    return PageViewModel(
      titleWidget: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: paddingTop),
            child: Center(
              child: Image.asset(
                'assets/images/illus_notifications.png',
                semanticLabel: 'Notifications illustration',
                width: illusSize,
                height: illusSize,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              "Notifications",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ],
      ),
      bodyWidget: Padding(
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: 20.0,
        ),
        child: Opacity(
          opacity: bodyOpacity,
          child: Text(
            body,
            style: TextStyle(
              fontSize: fontSizeDesc,
            ),
          ),
        ),
      ),
      footer: footer,
    );
  }

  Widget storeCard({@required Widget icon, @required url}) {
    return SizedBox(
      width: 100.0,
      height: 100.0,
      child: Card(
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: icon,
          ),
          onTap: () => launch(url),
        ),
      ),
    );
  }

  PageViewModel accountPVModel() {
    return PageViewModel(
      title: "Account",
      bodyWidget: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        child: Opacity(
            opacity: bodyOpacity,
            child: Text(
              "Create an account and you will be part of the community. "
              "Also, you will need it to propose new quotes "
              "and to save your most loved ones.",
              style: TextStyle(
                fontSize: fontSizeDesc,
              ),
            )),
      ),
      image: Center(
        child: Image.asset(
          'assets/images/illus_signin.png',
          semanticLabel: 'Account illustration',
          width: illusSize,
          height: illusSize,
        ),
      ),
      footer: isAuth
          ? Container()
          : ElevatedButton(
              onPressed: () {
                appStorage.setFirstLaunch();
                stateUser.setFirstLaunch(false);

                if (widget.isDesktop) {
                  Navigator.of(context).pop();

                  return Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Signin()),
                  );
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Signin();
                    },
                  ),
                );
              },
              child: Text("Sign in"),
            ),
    );
  }
}
