import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/animated_app_icon.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/push_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/base_page_app_bar.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/utils/app_localstorage.dart';
import 'package:figstyle/utils/snack.dart';

class DeleteAccount extends StatefulWidget {
  @override
  DeleteAccountState createState() => DeleteAccountState();
}

class DeleteAccountState extends State<DeleteAccount> {
  bool isDeleting = false;
  bool isCompleted = false;

  double beginY = 10.0;

  String password = '';

  @override
  initState() {
    super.initState();
    checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          appBar(),
          body(),
        ],
      ),
    );
  }

  Widget appBar() {
    return BasePageAppBar(
      expandedHeight: 90.0,
      title: Row(
        children: [
          CircleButton(
              onTap: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: stateColors.foreground)),
          AppIcon(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            size: 30.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete accouunt',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300,
                    color: stateColors.foreground,
                  ),
                ),
                Opacity(
                  opacity: .6,
                  child: Text(
                    'Well, this marks the end of the adventure',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: stateColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedView();
    }

    if (isDeleting) {
      return deletingView();
    }

    return idleView();
  }

  Widget completedView() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade300,
                size: 80.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 30.0,
              ),
              child: Text(
                'Your account has been successfuly deleted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
              ),
              child: Opacity(
                opacity: .6,
                child: Text(
                  'We hope to see you again',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 45.0,
              ),
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Home()));
                },
                child: Opacity(
                  opacity: .6,
                  child: Text(
                    'Back home',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ]));
  }

  Widget deletingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  'Deleting your data...',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: <Widget>[
              FadeInY(
                delay: 0.0,
                beginY: beginY,
                child: warningCard(),
              ),
              FadeInY(
                delay: 0.1,
                beginY: beginY,
                child: passwordInput(),
              ),
              FadeInY(
                delay: 0.2,
                beginY: beginY,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: validationButton(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 200.0),
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget imageTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 50.0),
      child: Image.asset(
        'assets/images/delete-user-${stateColors.iconExt}.png',
        width: 100.0,
      ),
    );
  }

  Widget passwordInput() {
    return SizedBox(
      width: 500.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Enter your password',
            ),
            autofocus: true,
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
    );
  }

  Widget textTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Text(
        'Delete account',
        style: TextStyle(
          fontSize: 35.0,
        ),
      ),
    );
  }

  Widget validationButton() {
    return OutlinedButton(
      onPressed: () => deleteAccount(),
      style: OutlinedButton.styleFrom(
        primary: Colors.red,
      ),
      child: SizedBox(
        width: 260.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                'DELETE ACCOUNT',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget warningCard() {
    return Container(
      width: 500.0,
      padding: EdgeInsets.only(
        top: 60.0,
        bottom: 40.0,
      ),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 16.0,
          ),
          title: Row(
            children: <Widget>[
              Icon(
                Icons.warning,
              ),
              Padding(padding: const EdgeInsets.only(left: 30.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Opacity(
                      opacity: .8,
                      child: Text(
                        'Are you sure?',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'This action is irreversible',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text(
                      'What happens after?',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // contentPadding: const EdgeInsets.all(25.0),
                    children: <Widget>[
                      Divider(
                        color: stateColors.secondary,
                        thickness: 1.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Your personal data will be deleted",
                              style: TextStyle(),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 15.0)),
                            Text(
                              "Your published quotes will stay on the platform",
                              style: TextStyle(),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 15.0)),
                            Text(
                              "Your username will (slowly) be dissaciated with the published quotes",
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }

  void checkAuth() async {
    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
      }
    } catch (error) {
      debugPrint(error.toString());
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
    }
  }

  void deleteAccount() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isDeleting = false;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final credentials = EmailAuthProvider.credential(
        email: userAuth.email,
        password: password,
      );

      await userAuth.reauthenticateWithCredential(credentials);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .update({'flag': 'delete'});

      await userAuth.delete();

      userState.signOut();
      userState.setUserName('');
      appLocalStorage.clearUserAuthData();

      PushNotifications.unlinkAuthUser();

      setState(() {
        isDeleting = false;
        isCompleted = true;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isDeleting = false;
      });

      showSnack(
        context: context,
        message: (error as PlatformException).message,
        type: SnackType.error,
      );
    }
  }

  bool inputValuesOk() {
    if (password.isEmpty) {
      showSnack(
        context: context,
        message: "Password cannot be empty.",
        type: SnackType.error,
      );

      return false;
    }

    return true;
  }
}
