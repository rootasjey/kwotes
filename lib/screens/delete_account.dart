import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/sliver_app_header.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/push_notifications.dart';
import 'package:memorare/utils/snack.dart';

class DeleteAccount extends StatefulWidget {
  @override
  DeleteAccountState createState() => DeleteAccountState();
}

class DeleteAccountState extends State<DeleteAccount> {
  bool isDeleting   = false;
  bool isCompleted  = false;

  String password   = '';

  double beginY     = 100.0;
  final delay       = 1.0;
  final delayStep   = 1.2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppHeader(
            title: 'Account deletion',
            subTitle: 'Well, this marks the end of the adventure',
          ),
          body(),
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
                padding: const EdgeInsets.only(top: 30.0,),
                child: Text(
                  'Your account has been successfuly deleted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10.0,),
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
                padding: const EdgeInsets.only(top: 45.0,),
                child: FlatButton(
                  onPressed: () {
                    FluroRouter.router.navigateTo(
                      context,
                      HomeRoute,
                    );
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
      ])
    );
  }

  Widget deletingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),

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
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              FadeInY(
                delay: delay + (0 * delayStep),
                beginY: beginY,
                child: warningCard(),
              ),

              FadeInY(
                delay: delay + (.5 * delayStep),
                beginY: beginY,
                child: passwordInput(),
              ),

              FadeInY(
                delay: delay + (1 * delayStep),
                beginY: beginY,
                child: validationButton(),
              ),

              Padding(padding: const EdgeInsets.only(bottom: 200.0),),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 80.0,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Enter your password',
            ),
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
    return RaisedButton(
      onPressed: () {
        deleteAccount();
      },
      color: stateColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(7.0),
        ),
      ),
      child: SizedBox(
        width: 240.0,
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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(Icons.warning),
        title: Opacity(
          opacity: .6,
          child: Text(
            'Are you sure?',
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "This action is irreversible",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
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
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Your personal data will be deleted",
                          style: TextStyle(
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(top: 15.0)),
                        Text(
                          "Your published quotes will stay",
                          style: TextStyle(
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(top: 15.0)),
                        Text(
                          "Your username will (slowly) be dissaciated with the published quotes",
                          style: TextStyle(
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          );
        },
      ),
    );
  }

  void deleteAccount() async {
    if (!inputValuesOk()) { return; }

    setState(() {
      isDeleting = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isDeleting = false;
        });

        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final credentials = EmailAuthProvider.getCredential(
        email: userAuth.email,
        password: password,
      );

      await userAuth.reauthenticateWithCredential(credentials);
      await PushNotifications.unsubMobileQuotidians(lang: userState.lang);

      await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .updateData({'flag': 'delete'});

      await userAuth.delete();

      userState.signOut();
      userState.setUserName('');
      appLocalStorage.clearUserAuthData();

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
